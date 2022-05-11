import NonFungibleToken from 0x{{.NonFungibleTokenAddress}}
import nfl_NFT from 0xef426ec51072f815


transaction(recipientAddress: Address, seriesId:UInt32, setId: UInt32, tokenIds: [UInt64]) {
    
    let recipient: &{NonFungibleToken.CollectionPublic}
    
    // local variable for the admin reference
    let admin: &nfl_NFT.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the Admin resource
        self.admin = signer.borrow<&nfl_NFT.Admin>(from: nfl_NFT.AdminStoragePath)
            ?? panic("Could not borrow a reference to the nfl_NFT Admin capability")
        
         // get the recipients public account object
        let recipientAccount = getAccount(recipientAddress)

        // borrow a public reference to the receivers collection
        self.recipient = recipientAccount.getCapability(nfl_NFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the collection receiver")
    }

    

    execute {
        // mint the NFT and deposit it to the recipient's collection
        self.admin.borrowSeries(seriesId:seriesId).batchMintnfl_NFT(recipient:self.recipient,setId: setId, tokenIds:tokenIds)
    }
}


