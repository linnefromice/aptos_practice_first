module use_oracle::price_oracle {
    #[test_only]
    use std::signer;
    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::block;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use use_oracle::math128;
    #[test_only]
    use switchboard::aggregator;
    #[test_only]
    use switchboard::math;
    #[test(aptos_framework = @aptos_framework)]
    fun test_aggregator(aptos_framework: &signer) {
        account::create_account_for_test(signer::address_of(aptos_framework));
        block::initialize_for_test(aptos_framework, 1);
        timestamp::set_time_has_started_for_testing(aptos_framework);

        let signers = unit_test::create_signers_for_testing(1);
        let acc1 = vector::borrow(&signers, 0);

        aggregator::new_test(acc1, 100, 0, false);
        let (val, dec, is_neg) = math::unpack(aggregator::latest_value(signer::address_of(acc1)));
        assert!(val == 100 * math128::pow_10((dec as u128)), 0);
        assert!(dec == 9, 0);
        assert!(is_neg == false, 0);
    }
}
