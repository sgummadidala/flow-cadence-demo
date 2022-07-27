/*
    Adapted from: AllDay.cdc
    Author: Corey Humeston corey.humeston@dapperlabs.com
*/


import NonFungibleToken from 0x{{.NonFungibleTokenAddress}}

/*
    AllDayTypeNFT is structured similarly to our AllDay.cdc.
    We encapsulate resource creation for the admin in member functions on the parent type.

    There are 3 levels of entities:
    1. Plays (will hold the Type of NFT on classification)
    2. Editions
    2. Type NFT (an NFT)

    An Edition is created from a Play and Type NFTs are minted out of Editions.

 */

// The AllDayType NFTs and metadata contract
//
pub contract AllDayTypeNFT: NonFungibleToken {
    //------------------------------------------------------------
    // Events
    //------------------------------------------------------------

    // Contract Events
    //
    pub event ContractInitialized()

    // NFT Collection Events
    //
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // Play Events
    //
    // Emitted when a new play has been created by an admin
    pub event PlayCreated(id: UInt64, classification: String, metadata: {String: String})

    // Edition Events
    //
    // Emitted when a new edition has been created by an admin
    pub event EditionCreated(
        id: UInt64,
        playID: UInt64,
        maxMintSize: UInt64?,
        tier: String,
    )
    // Emitted when an edition is either closed by an admin, or the max amount of moments have been minted
    pub event EditionClosed(id: UInt64)

    // NFT Events
    //
    pub event TypeNFTMinted(id: UInt64, editionID: UInt64, serialNumber: UInt64)
    pub event TypeNFTBurned(id: UInt64)

    //------------------------------------------------------------
    // Named values
    //------------------------------------------------------------

    // Named Paths
    //
    pub let CollectionStoragePath:  StoragePath
    pub let CollectionPublicPath:   PublicPath
    pub let AdminStoragePath:       StoragePath
    pub let MinterPrivatePath:      PrivatePath

    //------------------------------------------------------------
    // Publicly readable contract state
    //------------------------------------------------------------

    // Entity Counts
    //
    pub var totalSupply:        UInt64
    pub var nextPlayID:         UInt64
    pub var nextEditionID:      UInt64

    //------------------------------------------------------------
    // Internal contract state
    //------------------------------------------------------------

    // Metadata Dictionaries
    //
    access(self) let playByID:          @{UInt64: Play}
    access(self) let editionByID:       @{UInt64: Edition}

    //------------------------------------------------------------
    // Play
    //------------------------------------------------------------

    // A public struct to access Play data
    //
    pub struct PlayData {
        pub let id: UInt64
        pub let classification: String
        pub let metadata: {String: String}

        // initializer
        //
        init (id: UInt64) {
            if let play = &AllDayTypeNFT.playByID[id] as &AllDayTypeNFT.Play? {
            self.id = id
            self.classification = play.classification
            self.metadata = play.metadata
            } else {
                panic("play does not exist")
            }
        }
    }

    // A top level Play with a unique ID and a classification
    //
    pub resource Play {
        pub let id: UInt64
        pub let classification: String
        // Contents writable if borrowed!
        // This is deliberate, as it allows admins to update the data.
        pub let metadata: {String: String}

        // initializer
        //
        init (classification: String, metadata: {String: String}) {
            self.id = AllDayTypeNFT.nextPlayID
            self.classification = classification
            self.metadata = metadata

            AllDayTypeNFT.nextPlayID = self.id + 1 as UInt64

            emit PlayCreated(id: self.id, classification: self.classification, metadata: self.metadata)
        }
    }

    // Get the publicly available data for a Play
    //
    pub fun getPlayData(id: UInt64): AllDayTypeNFT.PlayData {
        pre {
            AllDayTypeNFT.playByID[id] != nil: "Cannot borrow play, no such id"
        }

        return AllDayTypeNFT.PlayData(id: id)
    }

    //------------------------------------------------------------
    // Edition
    //------------------------------------------------------------

    // A public struct to access Edition data
    //
    pub struct EditionData {
        pub let id: UInt64
        pub let playID: UInt64
        pub var maxMintSize: UInt64?
        pub let tier: String
        pub var numMinted: UInt64

       // member function to check if max edition size has been reached
       pub fun maxEditionMintSizeReached(): Bool {
            return self.numMinted == self.maxMintSize
        }

        // initializer
        //
        init (id: UInt64) {
           if let edition = &AllDayTypeNFT.editionByID[id] as &AllDayTypeNFT.Edition? {
            self.id = id
            self.playID = edition.playID
            self.maxMintSize = edition.maxMintSize
            self.tier = edition.tier
            self.numMinted = edition.numMinted
           } else {
               panic("edition does not exist")
           }
        }
    }

    // A top level Edition that contains a Play
    //
    pub resource Edition {
        pub let id: UInt64
        pub let playID: UInt64
        pub let tier: String
        // Null value indicates that there is unlimited minting potential for the Edition
        pub var maxMintSize: UInt64?
        // Updates each time we mint a new type nft for the Edition to keep a running total
        pub var numMinted: UInt64

        // Close this edition so that no more Type NFTs can be minted in it
        //
        access(contract) fun close() {
            pre {
                self.numMinted != self.maxMintSize: "max number of minted type nfts has already been reached"
            }

            self.maxMintSize = self.numMinted

            emit EditionClosed(id: self.id)
        }

        // Mint a Type NFT in this edition, with the given minting mintingDate.
        // Note that this will panic if the max mint size has already been reached.
        //
        pub fun mint(): @AllDayTypeNFT.NFT {
            pre {
                self.numMinted != self.maxMintSize: "max number of minted type nfts has been reached"
            }

            // Create the Type NFT, filled out with our information
            let typeNFT <- create NFT(
                id: AllDayTypeNFT.totalSupply + 1,
                editionID: self.id,
                serialNumber: self.numMinted + 1
            )
            AllDayTypeNFT.totalSupply = AllDayTypeNFT.totalSupply + 1
            // Keep a running total (you'll notice we used this as the serial number)
            self.numMinted = self.numMinted + 1 as UInt64

            return <- typeNFT
        }

        // initializer
        //
        init (
            playID: UInt64,
            maxMintSize: UInt64?,
            tier: String,
        ) {
            pre {
                maxMintSize != 0: "max mint size is zero, must either be null or greater than 0"
                AllDayTypeNFT.playByID.containsKey(playID): "playID does not exist"
            }

            self.id = AllDayTypeNFT.nextEditionID
            self.playID = playID

            // If an edition size is not set, it has unlimited minting potential
            if maxMintSize == 0 {
                self.maxMintSize = nil
            } else {
                self.maxMintSize = maxMintSize
            }

            self.tier = tier
            self.numMinted = 0 as UInt64

            AllDayTypeNFT.nextEditionID = AllDayTypeNFT.nextEditionID + 1 as UInt64

            emit EditionCreated(
                id: self.id,
                playID: self.playID,
                maxMintSize: self.maxMintSize,
                tier: self.tier,
            )
        }
    }

    // Get the publicly available data for an Edition
    //
    pub fun getEditionData(id: UInt64): EditionData {
        pre {
            AllDayTypeNFT.editionByID[id] != nil: "Cannot borrow edition, no such id"
        }

        return AllDayTypeNFT.EditionData(id: id)
    }

    //------------------------------------------------------------
    // NFT
    //------------------------------------------------------------

    // A Type NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub let editionID: UInt64
        pub let serialNumber: UInt64
        pub let mintingDate: UFix64

        // Destructor
        //
        destroy() {
            emit TypeNFTBurned(id: self.id)
        }

        // NFT initializer
        //
        init(
            id: UInt64,
            editionID: UInt64,
            serialNumber: UInt64
        ) {
            pre {
                AllDayTypeNFT.editionByID[editionID] != nil: "no such editionID"
                EditionData(id: editionID).maxEditionMintSizeReached() != true: "max edition size already reached"
            }

            self.id = id
            self.editionID = editionID
            self.serialNumber = serialNumber
            self.mintingDate = getCurrentBlock().timestamp

            emit TypeNFTMinted(id: self.id, editionID: self.editionID, serialNumber: self.serialNumber)
        }
    }

    //------------------------------------------------------------
    // Collection
    //------------------------------------------------------------

    // A public collection interface that allows Type NFTs to be borrowed
    //
    pub resource interface TypeNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowTypeNFT(id: UInt64): &AllDayTypeNFT.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Type NFT reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // An NFT Collection
    //
    pub resource Collection:
        NonFungibleToken.Provider,
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        TypeNFTCollectionPublic
    {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an UInt64 ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @AllDayTypeNFT.NFT
            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // batchDeposit takes a Collection object as an argument
        // and deposits each contained NFT into this Collection
        //
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {
            // Get an array of the IDs to be deposited
            let keys = tokens.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy tokens
        }

        // getIDs returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            pre {
                self.ownedNFTs[id] != nil: "Cannot borrow NFT, no such id"
            }

            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // borrowTypeNFT gets a reference to an NFT in the collection
        //
        pub fun borrowTypeNFT(id: UInt64): &AllDayTypeNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                if let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT? {
                    return ref! as! &AllDayTypeNFT.NFT
                }
                return nil
            } else {
                return nil
            }
        }

        // Collection destructor
        //
        destroy() {
            destroy self.ownedNFTs
        }

        // Collection initializer
        //
        init() {
            self.ownedNFTs <- {}
        }
    }

    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    //------------------------------------------------------------
    // Admin
    //------------------------------------------------------------

    // An interface containing the Admin function that allows minting NFTs
    //
    pub resource interface NFTMinter {
        // Mint a single NFT
        // The Edition for the given ID must already exist
        //
        pub fun mintNFT(editionID: UInt64): @AllDayTypeNFT.NFT
    }

    // A resource that allows managing metadata and minting NFTs
    //
    pub resource Admin: NFTMinter {
        // Borrow a Play
        //
        pub fun borrowPlay(id: UInt64): &AllDayTypeNFT.Play {
            pre {
                AllDayTypeNFT.playByID[id] != nil: "Cannot borrow play, no such id"
            }

            return (&AllDayTypeNFT.playByID[id] as &AllDayTypeNFT.Play?)!
        }

        // Borrow an Edition
        //
        pub fun borrowEdition(id: UInt64): &AllDayTypeNFT.Edition {
            pre {
                AllDayTypeNFT.editionByID[id] != nil: "Cannot borrow edition, no such id"
            }

            return (&AllDayTypeNFT.editionByID[id] as &AllDayTypeNFT.Edition?)!
        }


        // Create a Play
        //
        pub fun createPlay(classification: String, metadata: {String: String}): UInt64 {
            // Create and store the new play
            let play <- create AllDayTypeNFT.Play(
                classification: classification,
                metadata: metadata,
            )
            let playID = play.id
            AllDayTypeNFT.playByID[play.id] <-! play

            // Return the new ID for convenience
            return playID
        }

        // Create an Edition
        //
        pub fun createEdition(
            playID: UInt64,
            maxMintSize: UInt64?,
            tier: String): UInt64 {
            let edition <- create Edition(
                playID: playID,
                maxMintSize: maxMintSize,
                tier: tier,
            )
            let editionID = edition.id
            AllDayTypeNFT.editionByID[edition.id] <-! edition

            return editionID
        }

        // Close an Edition
        //
        pub fun closeEdition(id: UInt64): UInt64 {
            if let edition = &AllDayTypeNFT.editionByID[id] as &AllDayTypeNFT.Edition? {
                edition.close()
                return edition.id
            }
            panic("edition does not exist")
        }

        // Mint a single NFT
        // The Edition for the given ID must already exist
        //
        pub fun mintNFT(editionID: UInt64): @AllDayTypeNFT.NFT {
            pre {
                // Make sure the edition we are creating this NFT in exists
                AllDayTypeNFT.editionByID.containsKey(editionID): "No such EditionID"
            }

            return <- self.borrowEdition(id: editionID).mint()
        }
    }

    //------------------------------------------------------------
    // Contract lifecycle
    //------------------------------------------------------------

    // AllDayTypeNFT contract initializer
    //
    init() {
        // Set the named paths
        self.CollectionStoragePath = /storage/AllDayTypeNFTCollection
        self.CollectionPublicPath = /public/AllDayTypeNFTCollection
        self.AdminStoragePath = /storage/AllDayTypeNFTAdmin
        self.MinterPrivatePath = /private/AllDayTypeNFTMinter

        // Initialize the entity counts
        self.totalSupply = 0
        self.nextPlayID = 1
        self.nextEditionID = 1

        // Initialize the metadata lookup dictionaries
        self.playByID <- {}
        self.editionByID <- {}

        // Create an Admin resource and save it to storage
        let admin <- create Admin()
        self.account.save(<-admin, to: self.AdminStoragePath)
        // Link capabilites to the admin constrained to the Minter
        // and Metadata interfaces
        self.account.link<&AllDayTypeNFT.Admin{AllDayTypeNFT.NFTMinter}>(
            self.MinterPrivatePath,
            target: self.AdminStoragePath
        )

        // Let the world know we are here
        emit ContractInitialized()
    }
}
