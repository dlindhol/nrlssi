import latis.dm.Function
import latis.dm.RealSet
import latis.reader.TsmlReader
import latis.writer.BinaryWriter
import java.io.FileOutputStream

/**
 * Convert the two NRLSSI ASCII data files to a binary format that TSS1 can server.
 * 
 * Note, the LISIRD SSI binary format starts with the set of wavelength values
 * followed by the same number of irradiance values for each time sample.
 * The wavelength values are not repeated for each time sample.
 * The time values are not included at all. The NcML for TSS1 will define the times
 * assuming no missing samples.
 */
object NrlssiAsciiToLisirdBin {
  
  /**
   * Read the NRLSSI ASCII data via the given tsml file and extract the SSI data
   * as a TimeSeries of spectra.
   */
  def readSSI(file: String): Function[_] = {
    //make a reader for this tsml file and get the dataset
    var reader = new TsmlReader(file)
    val ds = reader.getDataset()
    
    //the dataset directly contains only the time series
    val f = ds.getVariable(0) //.asInstanceOf[Function] 
    
    //the second component of the time series' range is ssi, tsi is the first
    f.getVariable(1).asInstanceOf[Function[_]] 
    
    //TODO: close reader? use Iteratee?
  }
  
  /**
   * Given a spectrum (Function), return the wavelengths (domain set)
   * as an array of doubles.
   */
  def extractWavelengths(spectrum: Function[_]): Array[Double] = {
    spectrum.domain.asInstanceOf[RealSet].toDoubleArray
  }
  
  def main(args: Array[String]) {
    val ssi1 = readSSI("datasets/nrlssi_1950-1999.tsml")
    val ssi2 = readSSI("datasets/nrlssi_2000-2011.tsml")
    //combine ssi datasets
    val iter = ssi1.iterator ++ ssi2.iterator //TODO: support ssi1 ++ ssi2
    
    val out = new FileOutputStream("/data/NRLSSI/nrlssi.bin") //TODO: get from args?
    val writer = new BinaryWriter(out)
    
    //Iterate over time series samples
    var first = true
    for ((d,r) <- iter) {
      if (first) {
        //write the wavelength values for the first time sample only
        val wl = extractWavelengths(r.asInstanceOf[Function[_]])
        writer.write(wl)
        first = false
      }
      
      //write only the irradiance (range) values
      writer.writeVariable(r.asInstanceOf[Function[_]])
    }
    
    writer.close()
  }
}