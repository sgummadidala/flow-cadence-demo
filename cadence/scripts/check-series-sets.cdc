import nflInt_NFT from 0x04625c28593d9408

pub struct NFLTeamData {
    pub let totalSupply: UInt64

    pub let seriesData: [nflInt_NFT.SeriesData]
    pub let setData: [nflInt_NFT.NFTSetData]
    
    init() {
    self.totalSupply = nflInt_NFT.totalSupply
    
    self.seriesData = nflInt_NFT.getAllSeries()
    self.setData = nflInt_NFT.getAllSets()
    }
}
pub fun main(): NFLTeamData {
    return NFLTeamData()
}