/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

/* Projekt Green, by The Fair Token Project
 * 100% LP Lock
 * 0% burn
 * Projekt Telegram: recipient.me/projektgreen
 * FTP Telegram: recipient.me/fairtokenproject
 */ 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private m_Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        m_Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return m_Owner;
    }

    modifier onlyOwner() {
        require(m_Owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}  

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract ProjektGreen is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _blocks;
    mapping (address => uint256) private _bots;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private excludedAddress;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100000000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    
    string private _name = unicode"Projekt Green 🟢💵💵";
    string private _symbol = 'GREEN';
    uint8 private _decimals = 9;
    uint8 private _blockFlagThreshold = 4;
    uint256 private _banCount = 0;
    
    uint256 private _taxFee;
    uint256 private _fee;
    address payable private _feeAddress;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpened;
    bool private isSwap = false;
    bool private swapEnabled = false;
    uint256 private txLimit  = 500000000000 * 10**9;
    uint256 private safeTxLimit  = txLimit;
    uint256 private walletLimit = safeTxLimit.mul(4);

    event MaxOutTxLimit(uint txLimit);

    modifier lockTheSwap {
        isSwap = true;
        _;
        isSwap = false;
    }

    constructor () {
        _balances[address(this)] = _rTotal;
        excludedAddress[owner()] = true;
        excludedAddress[address(this)] = true;
        emit Transfer(address(0), address(this), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_balances[account]);
    }
    
    function banCount() external view returns (uint256){
        return _banCount;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _xT(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _xT(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function tokenFromReflection(uint256 amount) private view returns(uint256) {
        require(amount <= _rTotal, "Amount must be less than total reflections");
        uint256 rate =  _getRate();
        return amount.div(rate);
    }
    
    function setFeeAddress(address payable feeAddress) external onlyOwner() {
        _feeAddress = feeAddress;    
        excludedAddress[feeAddress] = true;
    }

    function _xT(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        uint256 recipientBalance = balanceOf(recipient);
        
        _fee = 3;
        
        if(recipient != uniswapV2Pair && recipient != address(uniswapV2Router))
            require(recipientBalance < walletLimit);
    
        if(sender != uniswapV2Pair)
            require(_bots[sender] < 3);
        
        if (sender != owner() && recipient != owner() && tradingOpened) {
                
            if (recipient != uniswapV2Pair && recipient != address(uniswapV2Router) && (block.number - _blocks[recipient]) <= 0)
                _banSeller(recipient);
                
            else if (recipient != uniswapV2Pair && recipient != address(uniswapV2Router) && (block.number - _blocks[recipient]) <= _blockFlagThreshold)
                _flagSeller(recipient);
            
            if (sender == uniswapV2Pair && recipient != address(uniswapV2Router) && !excludedAddress[recipient]) 
                require(amount <= txLimit);
            
            uint256 tokenBalance = balanceOf(address(this));
            if (!isSwap && sender != uniswapV2Pair && swapEnabled) {
                _swapTokensForETH(tokenBalance);
                uint256 ethBalance = address(this).balance;
                if(ethBalance > 0) {
                    _sendETHFee(address(this).balance);
                }
            }
        }
        
        bool takeFee = true;

        if(excludedAddress[sender] || excludedAddress[recipient]){
            takeFee = false;
        }
        
        _registerBlock(block.number, recipient);
        _tokenTransfer(sender,recipient,amount,takeFee);
    }

    function _swapTokensForETH(uint256 amount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
        
    function _sendETHFee(uint256 a) private {
        _feeAddress.transfer(a);
    }
    
    function addLiquidity() external onlyOwner() {
        require(!tradingOpened,"trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpened = true;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
        
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            _fee = 0;
        _transferStandard(sender, recipient, amount);
        if(!takeFee)
            _fee = 3;
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        (uint256 z, uint256 x, uint256 _a, uint256 y, uint256 _b, uint256 w) = _getValues(amount);
        _balances[sender] = _balances[sender].sub(z);
        _balances[recipient] = _balances[recipient].add(x); 
        _takeTeam(w);
        emit Transfer(sender, recipient, y);
    }

    function _takeTeam(uint256 a) private {
        uint256 c =  _getRate();
        uint256 b = a.mul(c);
        _balances[address(this)] = _balances[address(this)].add(b);
    }

    receive() external payable {}
    
    function manualSwapTokensForETH() external {
        require(_msgSender() == _feeAddress);
        uint256 cB = balanceOf(address(this));
        _swapTokensForETH(cB);
    }
    
    function manualTransferETHFee() external {
        require(_msgSender() == _feeAddress);
        uint256 ethBalance = address(this).balance;
        _sendETHFee(ethBalance);
    }
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _taxFee, _fee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setTxLimitMax() external onlyOwner() {
        txLimit = walletLimit;
        safeTxLimit = walletLimit;
        emit MaxOutTxLimit(txLimit);
    }
    
    function _registerBlock(uint b, address a) private {
        _blocks[a] = b;
    }
    
    function _flagSeller(address a) private {
        if(_bots[a] == 2)
            _banCount += 1;
        _bots[a] += 1;
    }
    
    function _banSeller(address a) private {
        if(_bots[a] < 3)
            _banCount += 1;
        _bots[a] += 3;
    }
    
    
    function _v(address a) external onlyOwner() {
        _bots[a] += 1;
    }
    
    function _u(address a) external onlyOwner() {
        _bots[a] = 0;
        _banCount -= 1;
    }
    
    function _k(uint8 a) external onlyOwner() {
        _blockFlagThreshold = a;
    }
}