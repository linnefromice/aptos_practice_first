module use_oracle::price_oracle {
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use aptos_framework::type_info;
    use use_oracle::math128;
    use switchboard::aggregator;
    use switchboard::math;

    // ref: https://github.com/switchboard-xyz/sbv2-aptos/tree/main/javascript/aptos.js#feed-addresses-same-on-devnet-and-testnet
    struct BTC {}
    struct ETH {}
    struct SOL {}
    struct USDC {}
    struct NEAR {}
    struct APT {}

    struct Storage has key {
        aggregators: simple_map::SimpleMap<String, address>
    }

    fun owner(): address {
        @use_oracle
    }

    public entry fun initialize(owner: &signer) {
        assert!(!exists<Storage>(signer::address_of(owner)), 0);
        move_to(owner, Storage { aggregators: simple_map::create<String, address>() })
    }

    fun key<C>(): String {
        type_info::type_name<C>()
    }

    public entry fun add_aggregator<C>(aggregator: address) acquires Storage {
        let owner_addr = owner();
        let key = key<C>();
        assert!(exists<Storage>(owner_addr), 0);
        assert!(!is_registered(key), 0);
        let aggrs = &mut borrow_global_mut<Storage>(owner_addr).aggregators;
        simple_map::add<String, address>(aggrs, key, aggregator);
    }
    fun is_registered(key: String): bool acquires Storage {
        let storage_ref = borrow_global<Storage>(owner());
        is_registered_internal(key, storage_ref)
    }
    fun is_registered_internal(key: String, storage: &Storage): bool {
        simple_map::contains_key(&storage.aggregators, &key)
    }

    fun price_from_aggregator(aggregator_addr: address): (u128, u8) {
        let latest_value = aggregator::latest_value(aggregator_addr);
        let (value, dec, _) = math::unpack(latest_value);
        (value, dec)
    }
    fun price_internal(key: String): (u128, u8) acquires Storage {
        let owner_addr = owner();
        assert!(exists<Storage>(owner_addr), 0);
        assert!(is_registered(key), 0);
        let aggrs = &borrow_global<Storage>(owner_addr).aggregators;
        let aggregator_addr = simple_map::borrow<String, address>(aggrs, &key);
        price_from_aggregator(*aggregator_addr)
    }
    public fun volume<C>(amount: u128): u128 acquires Storage {
        let (value, dec) = price_internal(key<C>());
        let numerator = amount * value;
        numerator / math128::pow_10((dec as u128))
    }
    public fun to_amount<C>(volume: u128): u128 acquires Storage {
        let (value, dec) = price_internal(key<C>());
        let numerator = volume * math128::pow_10((dec as u128));
        numerator / value
    }

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
