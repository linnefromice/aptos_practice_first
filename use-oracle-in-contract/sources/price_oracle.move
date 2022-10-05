module use_oracle::price_oracle {
    use std::signer;
    use switchboard::aggregator;

    #[test(account = @0x1)]
    fun test_aggregator(account: &signer) {
        aggregator::new_test(account, 100, 0, false);
        std::debug::print(&aggregator::latest_value(signer::address_of(account)));
    }
}