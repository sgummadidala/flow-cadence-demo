import NFL_NFT from 0x329feb3ab062d289

pub struct NFLTeamData {
    pub let totalSupply: UInt64

    pub let seriesData: [NFL_NFT.SeriesData]
    pub let setData: [NFL_NFT.NFTSetData]
    
    init() {
    self.totalSupply = NFL_NFT.totalSupply
    
    self.seriesData = NFL_NFT.getAllSeries()
    self.setData = NFL_NFT.getAllSets()
    }
}
pub fun main(): NFLTeamData {
    return NFLTeamData()
}