module use_oracle::pyth_oracle_v1 {
    use std::error;
    use std::signer;
    use std::string::String;
    use aptos_std::simple_map;
    use aptos_framework::type_info;
    use pyth::pyth;
    use pyth::price;
    use pyth::i64;
    use pyth::price_identifier;

    const ENOT_INITIALIZED: u64 = 1;
    const EALREADY_INITIALIZED: u64 = 2;
    const ENOT_REGISTERED: u64 = 3;
    const EALREADY_REGISTERED: u64 = 4;

    struct Storage has key {
        price_feed_ids: simple_map::SimpleMap<String, vector<u8>>
    }

    fun owner(): address {
        @use_oracle
    }

    fun key<C>(): String {
        type_info::type_name<C>()
    }

    public entry fun initialize(owner: &signer) {
        assert!(!exists<Storage>(signer::address_of(owner)), 0);
        move_to(owner, Storage { price_feed_ids: simple_map::create<String, vector<u8>>() });
    }

    public entry fun add_price_feed<C>(owner: &signer, price_feed_id: vector<u8>) acquires Storage {
        let owner_addr = owner();
        assert!(signer::address_of(owner) == owner_addr, 0);
        let key = key<C>();
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(!is_registered(key), error::invalid_argument(EALREADY_REGISTERED));
        let ids = &mut borrow_global_mut<Storage>(owner_addr).price_feed_ids;
        simple_map::add(ids, key, price_feed_id);
    }
    fun is_registered(key: String): bool acquires Storage {
        let storage_ref = borrow_global<Storage>(owner());
        is_registered_internal(key, storage_ref)
    }
    fun is_registered_internal(key: String, storage: &Storage): bool {
        simple_map::contains_key(&storage.price_feed_ids, &key)
    }

    ////////////////////////////////////////////////////
    /// Feed
    ////////////////////////////////////////////////////
    fun price_from_feeder(price_feed_id: vector<u8>): (u64, u64) {
        let identifier = price_identifier::from_byte_vec(price_feed_id);
        let price_obj = pyth::get_price(identifier);
        let price_mag = i64::get_magnitude_if_positive(&price::get_price(&price_obj));
        let expo_mag = i64::get_magnitude_if_positive(&price::get_expo(&price_obj));
        (price_mag, expo_mag) // TODO: use pyth::i64::I64.negative
    }
    fun price_internal(key: String): (u64, u64) acquires Storage {
        let owner_addr = owner();
        assert!(exists<Storage>(owner_addr), error::invalid_argument(ENOT_INITIALIZED));
        assert!(is_registered(key), error::invalid_argument(ENOT_REGISTERED));
        let price_feed_ids = &borrow_global<Storage>(owner_addr).price_feed_ids;
        let price_feed_id = simple_map::borrow(price_feed_ids, &key);
        price_from_feeder(*price_feed_id)
    }
    public fun price<C>(): (u64, u64) acquires Storage {
        let (value, dec) = price_internal(key<C>());
        (value, dec)
    }
    public fun price_of(name: &String): (u64, u64) acquires Storage {
        let (value, dec) = price_internal(*name);
        (value, dec)
    }
}