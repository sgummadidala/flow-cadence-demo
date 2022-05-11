import NonFungibleToken from 0x01
import nfl_NFT from 0x02

pub fun main(account: Address) {
    let receiver = getAccount(account)
        .getCapability(nfl_NFT.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()!

    let ids = receiver.getIDs()

	for nftId in ids {
		let nftValue: &nfl_NFT.NFT? = nfl_NFT.fetch(account,id:nftId)
		log("nft:")
		log("-----------------------")
		log("id:".concat(nftId.toString()))
		log("setId:")
    	log(nftValue?.setId)
		log("serialNumber:")
    	log(nftValue?.editionNum)
		log("-----------------------")
	}
}
