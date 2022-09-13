import NFTStorefront from 0x4eb8a10cb9f87357

pub fun main(account: Address): [UInt64] {
    let storefrontRef = getAccount(account)
        .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
            NFTStorefront.StorefrontPublicPath
        )
        .borrow()
        ?? panic("Could not borrow public storefront from address")

    let listingIDs = storefrontRef.getListingIDs() 
    
    return listingIDs
}