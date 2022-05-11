import nfl_NFT from 0xef426ec51072f815

transaction(seriesId: UInt32, setId: UInt32, maxEditions: UInt32, ipfsMetadataHashes: {UInt32: String},metadata: {String: String}) {
    // local variable for the admin reference
    let admin: &nfl_NFT.Admin
    prepare(signer: AuthAccount) {
        // borrow a reference to the Admin resource
        self.admin = signer.borrow<&nfl_NFT.Admin>(from: nfl_NFT.AdminStoragePath)
            ?? panic("Could not borrow a reference to the nfl_NFT Admin capability")
    }
    execute {
        self.admin.borrowSeries(seriesId:seriesId).addNftSet(
            setId: setId,
            maxEditions: maxEditions,
            ipfsMetadataHashes: ipfsMetadataHashes,
            metadata: metadata
        )
        log("====================================")
        log("New Set: ")
        log("SetID: ".concat(setId.toString()))
        log("====================================")
    }
}