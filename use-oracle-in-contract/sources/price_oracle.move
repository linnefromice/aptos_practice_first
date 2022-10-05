module use_oracle::price_oracle {
    use std::signer;
    use switchboard::aggregator;
    use switchboard::math;

    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
    // #[test_only]
    // use aptos_framework::account;
    #[test_only]
    fun initialize_signer_for_test(num_signers: u64): vector<signer> {
        let signers = unit_test::create_signers_for_testing(num_signers);

        // let i = vector::length<signer>(&signers);
        // while (i > 0) {
        //     let account = vector::borrow(&signers, i - 1);
        //     account::create_account_for_test(signer::address_of(account));
        //     i = i - 1;
        // };

        signers
    }
    #[test_only]
    fun borrow_account(accounts: &vector<signer>, index: u64): (&signer, address) {
        let account = vector::borrow(accounts, index);
        (account, signer::address_of(account))
    }
    #[test]
    fun test_aggregator() {
        let signers = initialize_signer_for_test(1);
        let (account, _) = borrow_account(&signers, 0);
        aggregator::new_test(account, 100, 0, false);
        let latest_value = aggregator::latest_value(signer::address_of(account));
        let (val, dec, is_neg) = math::unpack(latest_value);
        assert!(val == 100 * math::pow_10(dec), 0);
        assert!(dec == 9, 0);
        assert!(is_neg == false, 0);
    }
}
