//import latis.reader.TsmlReader
import latis.dm._

object SunspotProcessor extends App {

//  val reader = new TsmlReader("datasets/usaf_mwl.tsml")
//  val ds = reader.getDataset()
//  val f = ds.getVariable(0).asInstanceOf[Function[Variable]] 
  
  //TODO: ds.getVariable(name): Function
  
//  val extractStationName = (v: Variable) => v.getVariable(6).asInstanceOf[Text].string
//  //TODO: add "asString" to Variable, vs toString?, asDouble?
//  val g = f.range.groupBy(extractStationName)
//  //TODO: put range method on Variable, return self if not Function, then we don't need cast
//  for (t <- g("HOLL")) println(t)
  
  
  
  
  
  //TODO: group by group ID? or use coordinates, 2D domain?
  //  only used to detect duplicates
  
  //TODO: do we ever have duplicate records?
}