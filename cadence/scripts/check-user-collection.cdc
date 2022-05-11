import NonFungibleToken from 0x01
import nfl_NFT from 0x02

pub fun main(account: Address): [UInt64] {
    let receiver = getAccount(account)
        .getCapability(nfl_NFT.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()!

    return receiver.getIDs()
}
