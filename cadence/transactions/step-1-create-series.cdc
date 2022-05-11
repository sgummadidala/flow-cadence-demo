import nfl_NFT from 0xef426ec51072f815

transaction(seriesId: UInt32,metadata: {String: String}) {
    // local variable for the admin reference
    let admin: &nfl_NFT.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the Admin resource
        self.admin = signer.borrow<&nfl_NFT.Admin>(from: nfl_NFT.AdminStoragePath)
            ?? panic("Could not borrow a reference to the nfl Admin capability")
    }

    execute {
        self.admin.addSeries(
            seriesId: seriesId,
            metadata: metadata
        )

        log("====================================")
        log("New Series: ".concat(seriesId.toString()))
        log("====================================")
    }
}

