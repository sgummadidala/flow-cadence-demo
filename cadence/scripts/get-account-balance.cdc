import FungibleToken from 0x9a0766d93b6608b7

pub fun main(addr: Address): UFix64 {
    let cap = getAccount(addr)
        .getCapability<&{FungibleToken.Balance}>(/public/flowTokenBalance)

    if let moneys = cap.borrow() {
        return moneys.balance
    } else {
        return UFix64(0.0)
    }
}