module use_oracle::price_oracle {
    use std::error;
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use use_oracle::utils_module::{Self, key};
    use switchboard::aggregator;
    use switchboard::math;

    const ENOT_INITIALIZED: u64 = 1;
    const EALREADY_INITIALIZED: u64 = 2;
    const ENOT_REGISTERED: u64 = 3;
    const EALREADY_REGISTERED: u64 = 4;
    const EINACTIVE: u64 = 5;

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

    ////////////////////////////////////////////////////
    /// Manage module
    ////////////////////////////////////////////////////
    public entry fun initialize(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        utils_module::assert_owner(signer::address_of(owner));
        assert!(!exists<Storage>(owner_addr), error::invalid_argument(EALREADY_INITIALIZED));
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
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(!is_registered(key), error::invalid_argument(EALREADY_REGISTERED));
        let storage = borrow_global_mut<Storage>(owner_addr);
        simple_map::add<String, OracleContainer>(&mut storage.oracles, key, oracle);
    }
    fun is_registered(key: String): bool acquires Storage {
        let storage_ref = borrow_global<Storage>(utils_module::owner_address());
        is_registered_internal(key, storage_ref)
    }
    fun is_registered_internal(key: String, storage: &Storage): bool {
        simple_map::contains_key(&storage.oracles, &key)
    }

    public entry fun change_mode<C>(owner: &signer, new_mode: u8) acquires Storage {
        let owner_addr = signer::address_of(owner);
        let key = key<C>();
        utils_module::assert_owner(owner_addr);
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(is_registered(key), error::invalid_argument(ENOT_REGISTERED));
        let oracle_ref = simple_map::borrow_mut(&mut borrow_global_mut<Storage>(owner_addr).oracles, &key);
        oracle_ref.mode = new_mode;
    }

    public entry fun update_fixed_price<C>(owner: &signer, value: u128, dec: u8, neg: bool) acquires Storage {
        let owner_addr = signer::address_of(owner);
        let key = key<C>();
        utils_module::assert_owner(owner_addr);
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(is_registered(key), error::invalid_argument(ENOT_REGISTERED));
        let oracle_ref = simple_map::borrow_mut(&mut borrow_global_mut<Storage>(owner_addr).oracles, &key);
        oracle_ref.fixed_price = PriceDecimal { value, dec, neg };
    }


    ////////////////////////////////////////////////////
    /// Feed
    ////////////////////////////////////////////////////
    public fun price<C>(): (u128, u8) acquires Storage {
        price_internal(key<C>())
    }
    public fun price_of(key: String): (u128, u8) acquires Storage {
        price_internal(key)
    }
    fun price_internal(key: String): (u128, u8) acquires Storage {
        assert!(is_registered(key), error::invalid_argument(ENOT_REGISTERED));
        let oracle = simple_map::borrow(&borrow_global<Storage>(utils_module::owner_address()).oracles, &key);
        if (oracle.mode == FIXED_PRICE) return (oracle.fixed_price.value, oracle.fixed_price.dec);
        // if (oracle.mode == SWITCHBOARD) (0, 0) // TODO
        abort error::invalid_argument(EINACTIVE)
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
    #[expected_failure(abort_code = 65538)]
    fun test_initialize_twice(owner: &signer) {
        initialize(owner);
        initialize(owner);
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
    #[test(account = @0x1)]
    #[expected_failure(abort_code = 65537)]
    fun test_add_oracle_without_fixed_price_with_not_owner(account: &signer) acquires Storage {
        add_oracle_without_fixed_price<WETH>(account);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65537)]
    fun test_add_oracle_without_fixed_price_before_initialize(owner: &signer) acquires Storage {
        add_oracle_without_fixed_price<WETH>(owner);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65540)]
    fun test_add_oracle_without_fixed_price_twice(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_without_fixed_price<WETH>(owner);
        add_oracle_without_fixed_price<WETH>(owner);
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
    #[test(account = @0x1)]
    #[expected_failure(abort_code = 65537)]
    fun test_add_oracle_with_fixed_price_with_not_owner(account: &signer) acquires Storage {
        add_oracle_with_fixed_price<WETH>(account, 100, 9, false);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65537)]
    fun test_add_oracle_with_fixed_price_before_initialize(owner: &signer) acquires Storage {
        add_oracle_with_fixed_price<WETH>(owner, 100, 9, false);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65540)]
    fun test_add_oracle_with_fixed_price_twice(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_with_fixed_price<WETH>(owner, 100, 9, false);
        add_oracle_with_fixed_price<WETH>(owner, 100, 9, false);
    }

    #[test(owner = @use_oracle)]
    fun test_change_mode(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_without_fixed_price<WETH>(owner);
        change_mode<WETH>(owner, 9);

        let oracle = simple_map::borrow(&borrow_global<Storage>(signer::address_of(owner)).oracles, &key<WETH>());
        assert!(oracle.mode == 9, 0);
    }
    #[test(account = @0x1)]
    #[expected_failure(abort_code = 65537)]
    fun test_change_mode_with_not_owner(account: &signer) acquires Storage {
        change_mode<WETH>(account, 9);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65537)]
    fun test_change_mode_before_initialize(owner: &signer) acquires Storage {
        change_mode<WETH>(owner, 9);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65539)]
    fun test_change_mode_before_register_oracle(owner: &signer) acquires Storage {
        initialize(owner);
        change_mode<WETH>(owner, 9);
    }
    #[test(owner = @use_oracle)]
    fun test_update_fixed_price(owner: &signer) acquires Storage {
        initialize(owner);
        add_oracle_without_fixed_price<WETH>(owner);
        update_fixed_price<WETH>(owner, 1, 1, false);

        let oracle = simple_map::borrow(&borrow_global<Storage>(signer::address_of(owner)).oracles, &key<WETH>());
        assert!(oracle.fixed_price == PriceDecimal { value: 1, dec: 1, neg: false }, 0);
    }
    #[test(account = @0x1)]
    #[expected_failure(abort_code = 65537)]
    fun test_update_fixed_price_with_not_owner(account: &signer) acquires Storage {
        update_fixed_price<WETH>(account, 1, 1, false);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65537)]
    fun test_update_fixed_price_before_initialize(owner: &signer) acquires Storage {
        update_fixed_price<WETH>(owner, 100, 9, false);
    }
    #[test(owner = @use_oracle)]
    #[expected_failure(abort_code = 65539)]
    fun test_update_fixed_price_before_register_oracle(owner: &signer) acquires Storage {
        initialize(owner);
        update_fixed_price<WETH>(owner, 100, 9, false);
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
