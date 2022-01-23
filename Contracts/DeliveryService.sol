pragma solidity ^0.4.24;

contract DeliveryService {

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
   
    

    
       struct Restaurant {
        uint id;
        uint[] menu;
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
        order_deliveryboy_time = block.timestamp;



        uint restaurant_id = get_restaurant_id[msg.sender];
        require(order_details[order_id].rest == restaurant_id, "This is not your order ");
        require(order_details[order_id].status == OrderStatus.picked, "Package has not delivered yet");
           
        if(order_delivery_time - order_placing_time >= 60){
        emit warning("Late in food making, you will be deducted 10% from food fees");
                      
        }

        msg.sender.transfer(order_details[order_id].price); 
 


           
        return true;
    }
    

// Resutrant end     

// For delivery food package

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
    //order_deliverboy_time= block.timestamp;     
    order_delivery_time = block.timestamp;



        uint package_id = get_package_id[msg.sender];
        require(package_details[package_id].current_order == order_id, "Not your order");
        require(order_details[order_id].status == OrderStatus.prepared, "Food not yet made");
    
        emit order_update(order_id, OrderStatus.picked);
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

        if(order_receive_time - order_deliveryboy_time >= 60){
        emit warning("Late in food delivery, you will be deducted 5% from food delivery fees");
                      
        }
        msg.sender.transfer(delivery_fee);
        package_details[package_id].current_order = 0;
        
        return true;    
    }

//delivery end 


}

