import NonFungibleToken from 0x1d7e57aa55817448
import NFL_NFT from 0x329feb3ab062d289

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
        .getCapability(NFL_NFT.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()!
	
	let ids = receiver.getIDs()

	//let nftValue: &NFL_NFT.NFT? = NFL_NFT.fetch(account,id:nftId)
	//let userData = UserData(nftID:nftId,editionNum:nftValue?.editionNum,setID:nftValue?.setId)
	return ids
}
