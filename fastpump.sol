// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

interface Ifastpump {
    function get_balance(address user_adr, address token_adr) external view returns (uint);
        
    function run_fastbuy(address token_adr, address user_adr, uint x, bool is_v2) external;
    function run_fastsell(address token_adr, address user_adr, uint p, bool is_v2) external;
}

interface IWETH {
    function deposit() external payable;
}


contract fastpump {
    address private safe_c;
    address private owner;
    
    constructor() {
        //safe_c = address();
        owner = msg.sender;
    }
    
    fallback() external payable {}
    receive() external payable {}
    
    function safe_ap(address token, address to) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, uint(-1)));
        bool req = success && (data.length == 0 || abi.decode(data, (bool)));
        require(req, 'P');
    }
    
    ///////////////////////////////////////////////////////// user range
    
    function fast_buy(address token_adr, bool is_v2) external payable {
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IWETH(WETH).deposit{value: msg.value}();
        
        Ifastpump(safe_c).run_fastbuy(token_adr, msg.sender, msg.value, is_v2);
    }
    
    function fast_check_balance(address token_adr) external view returns (uint) {
        return Ifastpump(safe_c).get_balance(msg.sender, token_adr);
    }
    
    function fast_sell(uint percentage, address token_adr, bool is_v2) external payable {
        Ifastpump(safe_c).run_fastbuy(token_adr, msg.sender, percentage, is_v2);
        
        // gas save: no withdraw, just send WBNB to user
    }
    
    
    ///////////////////////////////////////////////////////// admin range
    
    function set_safe_c(address _safe_c) external {
        require(msg.sender == owner, 'O');
        
        address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        safe_c = _safe_c;
        safe_ap(WETH, _safe_c);
    }
    
}

















