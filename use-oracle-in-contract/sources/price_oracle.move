module use_oracle::price_oracle {
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use use_oracle::utils_module;
    use switchboard::aggregator;
    use switchboard::math;

    const INACTIVE: u8 = 0;
    const FIXED_PRICE: u8 = 1;
    const SWITCHBOARD: u8 = 2;

    struct Storage has key {
        oracles: simple_map::SimpleMap<String, OracleInfo>
    }
    struct OracleInfo has store {
        mode: u8,
        fixed_price: PriceDecimal
    }
    struct PriceDecimal has copy, drop, store { value: u128, dec: u8, neg: bool }

    public entry fun initialize(owner: &signer) {
        utils_module::assert_owner(signer::address_of(owner));
        move_to(owner, Storage { oracles: simple_map::create<String, OracleInfo>() });
    }

    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
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
