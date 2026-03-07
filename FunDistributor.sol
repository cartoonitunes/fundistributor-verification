contract FunDistributor {
    address receiver;
    uint lastBlock;
    uint touchInterval;

    function FunDistributor() {
        lastBlock = block.number;
        touchInterval = 200;
        receiver = msg.sender;
    }

    function touch() {
        payout();
        if (msg.value * 100 > this.balance) {
            receiver = msg.sender;
            lastBlock = block.number;
        } else {
            msg.sender.send(msg.value);
        }
    }

    function get_receiver() constant returns (address) {
        return receiver;
    }

    function get_target_block() constant returns (uint) {
        return lastBlock + touchInterval + 1;
    }

    function get_touch_interval() constant returns (uint) {
        return touchInterval;
    }

    function payout() private {
        if (block.number > lastBlock + touchInterval) {
            receiver.send(this.balance / 3);
            touchInterval = touchInterval + touchInterval / 200;
            lastBlock = block.number;
        }
    }
}
