module use_oracle::switchboard_adaptor {
    use std::error;
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use switchboard::aggregator;
    use switchboard::math;
    use use_oracle::utils_module::{Self, key};

    const ENOT_INITIALIZED: u64 = 1;
    const EALREADY_INITIALIZED: u64 = 2;
    const ENOT_REGISTERED: u64 = 3;
    const EALREADY_REGISTERED: u64 = 4;

    struct Storage has key {
        aggregators: simple_map::SimpleMap<String, address>
    }

    public entry fun initialize(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        utils_module::assert_owner(signer::address_of(owner));
        assert!(!exists<Storage>(owner_addr), error::invalid_argument(EALREADY_INITIALIZED));
        move_to(owner, Storage { aggregators: simple_map::create<String, address>() })
    }

    public entry fun add_aggregator<C>(owner: &signer, aggregator: address) acquires Storage {
        let owner_addr = signer::address_of(owner);
        utils_module::assert_owner(owner_addr);
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        let key = key<C>();
        let aggrs = &mut borrow_global_mut<Storage>(owner_addr).aggregators;
        simple_map::add<String, address>(aggrs, key, aggregator);
    }
    fun is_registered(key: String): bool acquires Storage {
        let storage_ref = borrow_global<Storage>(utils_module::owner_address());
        is_registered_internal(key, storage_ref)
    }
    fun is_registered_internal(key: String, storage: &Storage): bool {
        simple_map::contains_key(&storage.aggregators, &key)
    }

    fun price_from_aggregator(aggregator_addr: address): (u128, u8) {
        let latest_value = aggregator::latest_value(aggregator_addr);
        let (value, dec, _) = math::unpack(latest_value);
        (value, dec) // TODO: use neg in struct SwitchboardDecimal
    }
    fun price_internal(key: String): (u128, u8) acquires Storage {
        let owner_addr = utils_module::owner_address();
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(!is_registered(key), error::invalid_argument(EALREADY_REGISTERED));
        let aggrs = &borrow_global<Storage>(owner_addr).aggregators;
        let aggregator_addr = simple_map::borrow<String, address>(aggrs, &key);
        price_from_aggregator(*aggregator_addr)
    }
    public fun price<C>(): (u128, u8) acquires Storage {
        let (value, dec) = price_internal(key<C>());
        (value, dec)
    }
    public fun price_of(name: &String): (u128, u8) acquires Storage {
        let (value, dec) = price_internal(*name);
        (value, dec)
    }

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