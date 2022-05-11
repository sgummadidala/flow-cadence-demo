import nfl_NFT from 0x02

pub struct NFLTeamData {
    pub let totalSupply: UInt64

    pub let seriesData: [nfl_NFT.SeriesData]
    pub let setData: [nfl_NFT.NFTSetData]
    
    init() {
    self.totalSupply = nfl_NFT.totalSupply
    
    self.seriesData = nfl_NFT.getAllSeries()
    self.setData = nfl_NFT.getAllSets()
    }
}
pub fun main(): NFLTeamData {
    return NFLTeamData()
}