import NonFungibleToken from 0x1d7e57aa55817448
import AllDay from 0xe4cf4bdc1751c65d

pub struct UserData {
	pub let nftID: UInt64
	pub let editionNum: UInt32?
    pub let setID: UInt32?

	 init (nftID: UInt64,editionNum: UInt32?,setID: UInt32?) {
            self.nftID = nftID
            self.editionNum = editionNum
            self.setID = setID
        }
}
pub fun main(account: Address): [UInt64] {

	let receiver = getAccount(account)
        .getCapability(AllDay.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()!
	
	let ids = receiver.getIDs()

	return ids

}
