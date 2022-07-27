    import AllDay from 0xe4cf4bdc1751c65d
      import PDS from 0x44c6a6fd2281b6cc
      import PackNFT from 0xe4cf4bdc1751c65d
  
      pub struct NFLData {
        pub let totalMomentsSupply: UInt64
        pub let totalPacksSupply: UInt64
  
        pub let nextSeriesID: UInt64
        pub let nextSetID: UInt64
        pub let nextPlayID: UInt64
        pub let nextEditionID: UInt64
        pub let nextDistID: UInt64
  
        pub let seriesData: [AllDay.SeriesData]
        pub let setData: [AllDay.SetData]
        pub let playData: [AllDay.PlayData]
        pub let editionData: [AllDay.EditionData]
        pub let distData: [PDS.DistInfo?]
        
        init() {
          self.totalMomentsSupply = AllDay.totalSupply
          self.totalPacksSupply = PackNFT.totalSupply
          self.nextSeriesID = AllDay.nextSeriesID
          self.nextSetID = AllDay.nextSetID
          self.nextPlayID = AllDay.nextPlayID
          self.nextEditionID = AllDay.nextEditionID
          self.nextDistID = PDS.nextDistId
          
          self.seriesData = []
          var seriesID = UInt64(1)
          while seriesID < self.nextSeriesID {
            self.seriesData.append(AllDay.getSeriesData(id: seriesID))
            seriesID = seriesID + UInt64(1)
          }
  
          self.setData = []
          var setID = UInt64(1)
          while setID < self.nextSetID {
            self.setData.append(AllDay.getSetData(id: setID))
            setID = setID + UInt64(1)
          }
  
          self.playData = []
          var playID = UInt64(1)
          while playID < self.nextPlayID {
            self.playData.append(AllDay.getPlayData(id: playID))
            playID = playID + UInt64(1)
          }
  
          self.editionData = []
          var editionID = UInt64(1)
          while editionID < self.nextEditionID {
            self.editionData.append(AllDay.getEditionData(id: editionID))
            editionID = editionID + UInt64(1)
          }
  
          self.distData = []
          var distID = UInt64(1)
          while distID < self.nextDistID {
            self.distData.append(PDS.getDistInfo(distId: distID))
            distID = distID + UInt64(1)
          }
        }
      }
      pub fun main(): NFLData {
        return NFLData()
      }