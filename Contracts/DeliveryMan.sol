pragma solidity ^0.4.24;

import './Restaurant.sol';
import './Customer.sol';


contract DeliveryMan {

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
    

// / For delivery food package

    function package_registration() 
    public returns(bool) {
        require(get_package_id[msg.sender] == 0, "Package registered");
        
        package_count++;
        Package storage p = package_details[package_count];
        p.id = package_count;
        p.loc_x = 7;
        p.loc_y = 7;
        package_details[p.id] = p;
        get_package_id[msg.sender] = p.id;
        return true;
    }
    

    modifier is_package() {
        require(get_package_id[msg.sender] > 0, "No package registered");
        _;
    }

 
    function accept_package(uint order_id)
    is_package()
    public payable returns (bool) {
        uint package_id = get_package_id[msg.sender];
        require(package_details[package_id].current_order == 0, "Already delivering another order");
        require(order_details[order_id].status == OrderStatus.accepted, "Already claimed");
        
        emit order_update(order_id, OrderStatus.package_found);
        order_details[order_id].status = OrderStatus.package_found;
        order_details[order_id].del = get_package_id[msg.sender];
        package_details[package_id].current_order = order_id;
        
        return true;
    }



    
    function collect_food(uint order_id)
    is_package()
    public returns (bool) {
  
    order_delivery_time = block.timestamp;



        uint package_id = get_package_id[msg.sender];
        require(package_details[package_id].current_order == order_id, "Not your order");
        require(order_details[order_id].status == OrderStatus.prepared, "Food not yet made");
    
        emit order_update(order_id, OrderStatus.picked);
        emit event2("Your package has been received by the deliveryman");
        order_details[order_id].status = OrderStatus.picked;

        return true;
        
    }
    
    function deliver_food(uint order_id)
    is_package()
    public returns (bool) {
        uint package_id = get_package_id[msg.sender];
        require(package_details[package_id].current_order == order_id, "Not your order");
        require(order_details[order_id].status == OrderStatus.picked, "Food not yet picked");
        
        
        return true;    
        
    }
    
    function collect_delivery_fee(uint order_id)
    is_package()
    public returns (bool) {
        uint package_id = get_package_id[msg.sender];
        require(package_details[package_id].current_order == order_id, "Not your order");
        require(order_details[order_id].status == OrderStatus.delivered, "Food not yet delivered");

        if(order_receive_time - order_deliveryman_time > 60){
        emit warning("Late in food delivery, you will be deducted 5% from food delivery fees");
                      
        }
        msg.sender.transfer(delivery_fee);
        package_details[package_id].current_order = 0;
        
        return true;    
    }

//delivery end 


}





    
