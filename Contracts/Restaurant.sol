pragma solidity ^0.4.24;

import './Customer.sol';
import './DeliveryMan.sol';


contract Restaurant {

    uint package_count = 0;
    uint restaurant_count = 0;
    uint customer_count = 0;
    uint order_count = 0;
    uint delivery_fee = 0;
    uint food_cost = 0;
    uint256 order_placing_time;
    uint256 order_delivery_time;
    uint256 order_deliveryman_time;
    uint256 order_receive_time;
 

    
    enum OrderStatus {ordered, accepted, package_found, prepared, picked, delivered}
   
    

    
       struct Restaurant {
        uint id;
        uint [] menu;
        uint loc_x;
        uint loc_y;
        uint order_count;
    }
    
    struct Customer {
        uint id;
        uint a_order;
        uint b_order;

    }
    
        struct Package {
        uint id;
        uint current_order;
        uint package_order;
        uint loc_x;
        uint loc_y;
        uint order_count;
    }
    
    
        struct Order {
        uint id; 
        uint[] food_items;
        uint price;
        uint rest;
        uint del;
        uint cust;
        OrderStatus status;
       
    }
    
    
    mapping(address => uint) get_restaurant_id;
    mapping(address => uint ) get_package_id;
    mapping(address => uint) get_customer_id;
    
    
    mapping(uint => Customer) customer_details;
    mapping(uint => Restaurant) restaurant_details;
    mapping(uint => Package) package_details;
    mapping(uint => Order) order_details;

    event order_update(uint order_id, OrderStatus status);

    event event1(string msg);
    event event2(string msg);
    event event3(string msg);
    



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
    

 


// For resturant owner 

    
    function restaurant_registration() 
    public returns(bool) {
        require(get_restaurant_id[msg.sender] == 0, "Restaurant registered");

        restaurant_count++;
        Restaurant storage r = restaurant_details[restaurant_count];
        r.id = restaurant_count;
        r.loc_x = 7;
        r.loc_y = 7;
        r.menu.push(1);
        r.menu.push(2);
        r.menu.push(3);
        r.menu.push(4);
        r.menu.push(5);
        r.menu.push(6);
        r.menu.push(7);
        r.menu.push(8);
        r.menu.push(9);
        r.menu.push(10);        
        restaurant_details[r.id] = r;
        get_restaurant_id[msg.sender] = r.id;
        return true;
    }
    

    modifier is_restaurant() {
        require(get_restaurant_id[msg.sender] > 0, "This resturant is not registered");
        _;
    }

    

    function order_accept(uint order_id)
    is_restaurant
    public returns (bool) {
        uint restaurant_id = get_restaurant_id[msg.sender];
        require(order_details[order_id].rest == restaurant_id, "Not your order");
        require(order_details[order_id].status == OrderStatus.ordered, "Already accepted this order");
    
        emit order_update(order_id, OrderStatus.accepted);
        emit event1("Your order has been placed");
        order_details[order_id].status = OrderStatus.accepted;
        
        return true;
    }

    
    function food_making(uint order_id)
    is_restaurant()
    public returns (bool) {
        order_placing_time = block.timestamp;
        uint restaurant_id = get_restaurant_id[msg.sender];
        require(order_details[order_id].rest == restaurant_id, "This is not your order ");
        require(order_details[order_id].status == OrderStatus.package_found, "No package found ");
    
        emit order_update(order_id, OrderStatus.prepared);
        order_details[order_id].status = OrderStatus.prepared;
        
        return true;
    }

    
    function food_fee_collecting(uint order_id)
    is_restaurant()
    public returns (bool) {
        order_deliveryman_time = block.timestamp;



        uint restaurant_id = get_restaurant_id[msg.sender];
        require(order_details[order_id].rest == restaurant_id, "This is not your order ");
        require(order_details[order_id].status == OrderStatus.picked, "Package has not delivered yet");
           
        if(order_delivery_time - order_placing_time > 60){
        emit warning("Late in food making, you will be deducted 10% from food fees");
                      
        }

        msg.sender.transfer(order_details[order_id].price); 
 


           
        return true;
    }
    

// Resutrant end     



}





    
