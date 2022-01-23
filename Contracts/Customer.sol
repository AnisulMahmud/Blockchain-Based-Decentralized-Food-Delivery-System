pragma solidity ^0.4.24;

import './Restaurant.sol';
import './DeliveryBoy.sol';

contract Customer {

    uint package_count = 0;
    uint restaurant_count = 0;
    uint customer_count = 0;
    uint order_count = 0;
    uint delivery_fee = 0;
    uint food_cost = 0;
    uint256 order_placing_time;
    uint256 order_delivery_time;
    uint256 order_deliveryboy_time;
    uint256 order_receive_time;

    
    enum OrderStatus {ordered, accepted, package_found, prepared, picked, delivered}
   
    


    
    struct Customer {
        uint id;
        uint a_order;
        uint b_order;

    }
    
    
    
        struct Order {
        uint id; 
        uint[] food_items;
        uint price;
        uint rest;
        uint del;
        uint cust;
        OrderStatus status;
        uint time;
    }
    
    
    mapping(address => uint) get_restaurant_id;
    mapping(address => uint ) get_package_id;
    mapping(address => uint) get_customer_id;
    
    
    mapping(uint => Customer) customer_details;
    mapping(uint => Restaurant) restaurant_details;
    mapping(uint => Package) package_details;
    mapping(uint => Order) order_details;

    event order_update(uint order_id, OrderStatus status);
    



    event warning(string msg);

    
        function get_id()
    public view returns(uint) {
        uint id;
        id = get_customer_id[msg.sender];
        if (id != 0)
            return id;
            
        id = get_package_id[msg.sender];
        if (id != 0)
            return id;
            
        id = get_restaurant_id[msg.sender];
        if (id != 0)
            return id;
            
        require(id != 0, "You aren't registered");
        return 0;
    }
    

    
    
    function food_available(uint item, uint restaurant_id) 
    public view returns(bool) {
        uint i;
        for (i = 0; i < restaurant_details[restaurant_id].menu.length; i++) {
            if (restaurant_details[restaurant_id].menu[i] == item) {
                return true;
            }
        }
        return false;
    }
    

    // FOR us or Customer 

    function customer_registration() 
    public returns(bool) {
        require(get_customer_id[msg.sender] == 0, "Customer registered");
        
        customer_count++;
        Customer storage c = customer_details[customer_count];
        c.id = customer_count;
        c.a_order = 0;
        customer_details[c.id] = c;
        get_customer_id[msg.sender] = c.id;
        return true;
    }


    modifier is_customer() {
        require(get_customer_id[msg.sender] > 0, "You aren't registered");
        _;
    }    

    modifier has_ordered() {
        require(customer_details[get_customer_id[msg.sender]].a_order != 0, "You don't have any ordered package ");
        _;
    }

    
        
    
        function place_order(uint[] food_items, uint restaurant_id)
    is_customer()
    public payable returns(bool) {
        require(restaurant_id <= restaurant_count, "Restaurant doesn't exist");
        require(customer_details[get_customer_id[msg.sender]].a_order == 0, "Already placed order");
        require(food_items.length * food_cost + delivery_fee == msg.value, "Insufficient amount");
        uint i;
        for (i = 0; i < food_items.length; i++) {
            require(food_available(food_items[i], restaurant_id) == true, "Food Item doesn't exist");
        }
        
        
        order_count++;
        Order storage o = order_details[order_count];
        o.id = order_count;
        o.food_items = food_items;
        o.price = food_items.length * food_cost;
        o.status = OrderStatus.ordered;
        o.rest = restaurant_id;
        o.cust = get_customer_id[msg.sender];
        
        customer_details[get_customer_id[msg.sender]].a_order = o.id;
        emit order_update(o.id, o.status);
        return true;
        
    }

    function food_arrival()
    is_customer()
    has_ordered()
    public returns (bool) {

    order_receive_time= block.timestamp;

        uint order_id = customer_details[get_customer_id[msg.sender]].a_order;
        order_details[order_id].status = OrderStatus.delivered;
        customer_details[get_customer_id[msg.sender]].a_order = 0;
        customer_details[get_customer_id[msg.sender]].b_order = order_id;
        emit order_update(order_id, OrderStatus.delivered);
        
        return true;
    } 

    function food_status()
    is_customer()
    has_ordered()
    public view returns (OrderStatus) {
        uint order_id = customer_details[get_customer_id[msg.sender]].a_order;
        return order_details[order_id].status;
    }       
    

// Customer end 

}
    
