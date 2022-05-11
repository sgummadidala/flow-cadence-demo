import NonFungibleToken from 0x631e88ae7f1d7c20
import nfl_NFT from 0xef426ec51072f815
 
// This transaction configures an account to hold our nfl NFTs.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&nfl_NFT.Collection>(from: nfl_NFT.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- nfl_NFT.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: nfl_NFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&nfl_NFT.Collection{NonFungibleToken.CollectionPublic, nfl_NFT.nfl_NFTCollectionPublic}>(
                nfl_NFT.CollectionPublicPath,
                target: nfl_NFT.CollectionStoragePath
            )
        }
    }
}
