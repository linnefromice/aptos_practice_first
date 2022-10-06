module use_oracle::price_oracle {
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use use_oracle::utils_module::{Self, key};
    use switchboard::aggregator;
    use switchboard::math;

    const INACTIVE: u8 = 0;
    const FIXED_PRICE: u8 = 1;
    const SWITCHBOARD: u8 = 2;

    struct Storage has key {
        oracles: simple_map::SimpleMap<String, OracleContainer>
    }
    struct OracleContainer has store {
        mode: u8,
        is_enabled_fixed_price: bool,
        fixed_price: PriceDecimal
    }
    struct PriceDecimal has copy, drop, store { value: u128, dec: u8, neg: bool }

    public entry fun initialize(owner: &signer) {
        utils_module::assert_owner(signer::address_of(owner));
        move_to(owner, Storage { oracles: simple_map::create<String, OracleContainer>() });
    }

    public entry fun add_oracle_without_fixed_price<C>(account: &signer) acquires Storage {
        add_oracle(account, key<C>(), OracleContainer {
            mode: INACTIVE,
            is_enabled_fixed_price: false,
            fixed_price: PriceDecimal { value: 0, dec: 0, neg: false }
        });
    }

    public entry fun add_oracle_with_fixed_price<C>(account: &signer, value: u128, dec: u8, neg: bool) acquires Storage {
        add_oracle(account, key<C>(), OracleContainer {
            mode: INACTIVE,
            is_enabled_fixed_price: true,
            fixed_price: PriceDecimal { value, dec, neg }
        });
    }

    fun add_oracle(owner: &signer, key: String, oracle: OracleContainer) acquires Storage {
        let owner_addr = signer::address_of(owner);
        utils_module::assert_owner(owner_addr);
        let storage = borrow_global_mut<Storage>(owner_addr);
        simple_map::add<String, OracleContainer>(&mut storage.oracles, key, oracle);
    }

    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
    #[test_only]
    struct WETH {}
    #[test(owner = @use_oracle)]
    fun test_initialize(owner: &signer) {
        initialize(owner);
        assert!(exists<Storage>(signer::address_of(owner)), 0);
    }
    #[test(account = @0x1)]
    #[expected_failure(abort_code = 65537)]
    fun test_initialize_with_not_owner(account: &signer) {
        initialize(account);
    }
    #[test(owner = @use_oracle)]
    fun test_add_oracle_without_fixed_price(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_without_fixed_price<WETH>(owner);
        let oracle = simple_map::borrow(&borrow_global<Storage>(signer::address_of(owner)).oracles, &key<WETH>());
        assert!(oracle.mode == 0, 0);
        assert!(oracle.is_enabled_fixed_price == false, 0);
        assert!(oracle.fixed_price == PriceDecimal { value: 0, dec: 0, neg: false }, 0);
    }
    #[test(owner = @use_oracle)]
    fun test_add_oracle_with_fixed_price(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_with_fixed_price<WETH>(owner, 100, 9, false);
        let oracle = simple_map::borrow(&borrow_global<Storage>(signer::address_of(owner)).oracles, &key<WETH>());
        assert!(oracle.mode == 0, 0);
        assert!(oracle.is_enabled_fixed_price == true, 0);
        assert!(oracle.fixed_price == PriceDecimal { value: 100, dec: 9, neg: false }, 0);
    }
    
    #[test]
    fun test_aggregator() {
        let signers = unit_test::create_signers_for_testing(1);

        let acc1 = vector::borrow(&signers, 0);
        aggregator::new_test(acc1, 100, 0, false);
        let (val, dec, is_neg) = math::unpack(aggregator::latest_value(signer::address_of(acc1)));
        assert!(val == 100 * math::pow_10(dec), 0);
        assert!(dec == 9, 0);
        assert!(is_neg == false, 0);        
    }
}
