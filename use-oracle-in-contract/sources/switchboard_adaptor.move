module use_oracle::switchboard_adaptor {
    use std::signer;
    use switchboard::aggregator;
    use switchboard::math;

    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
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