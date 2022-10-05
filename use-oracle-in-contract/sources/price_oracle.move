module use_oracle::price_oracle {
    use std::signer;
    use switchboard::aggregator;
    use switchboard::math;

    #[test_only]
    use std::vector;
    #[test_only]
    use std::unit_test;
    #[test_only]
    use aptos_std::debug;
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
    fun borrow_account(accounts: &vector<signer>, index: u64): &signer {
        let account = vector::borrow(accounts, index);
        account
        // (account, signer::address_of(account))
    }
    #[test]
    fun test_aggregator() {
        let signers = initialize_signer_for_test(1);

        let acc1 = borrow_account(&signers, 0);
        aggregator::new_test(acc1, 100, 0, false);
        let (val, dec, is_neg) = math::unpack(aggregator::latest_value(signer::address_of(acc1)));
        assert!(val == 100 * math::pow_10(dec), 0);
        assert!(dec == 9, 0);
        assert!(is_neg == false, 0);        
    }

    #[test_only]
    fun debug_latest_value(account: &signer, value: u128, dec: u8, sign: bool) {
        aggregator::new_test(account, value, dec, sign);
        debug::print(&aggregator::latest_value(signer::address_of(account)));
    }
    #[test]
    #[expected_failure]
    fun test_aggregator_with_decimals() {
        let signers = unit_test::create_signers_for_testing(11);
        debug_latest_value(borrow_account(&signers, 0), 100, 0, false); // { 100000000000, 9, false }
        debug_latest_value(borrow_account(&signers, 1), 1, 1, false); // { 100000000, 9, false }
        debug_latest_value(borrow_account(&signers, 2), 2, 2, false); // { 20000000, 9, false }
        debug_latest_value(borrow_account(&signers, 3), 3, 3, false); // { 3000000, 9, false }
        debug_latest_value(borrow_account(&signers, 4), 4, 4, false); // { 400000, 9, false }
        debug_latest_value(borrow_account(&signers, 5), 5, 5, false); // { 50000, 9, false }
        debug_latest_value(borrow_account(&signers, 6), 6, 6, false); // { 6000, 9, false }
        debug_latest_value(borrow_account(&signers, 7), 7, 7, false); // { 700, 9, false }
        debug_latest_value(borrow_account(&signers, 8), 8, 8, false); // { 80, 9, false }
        debug_latest_value(borrow_account(&signers, 9), 9, 9, false); // { 9, 9, false }
        debug_latest_value(borrow_account(&signers, 10), 10, 10, false); // fail here - assert!(dec <= MAX_DECIMALS, EMORE_THAN_9_DECIMALS);
    }
}
