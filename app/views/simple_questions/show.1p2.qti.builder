xml.instruct!

xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
xml.Document {
  xml.name("Test")
  xml.open(1)
  xml.visible(1)
  xml.NetworkLink {
    xml.name("My rails app  being passed parameters")
    xml.open(1)
    xml.visibility(0)
    xml.Link {
      xml.href("hi")
      xml.viewRefreshMode("onStop")
      xml.viewRefreshTime(0.5)
      xml.viewFormat("BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]&CENTRE=[lookatLon],[lookatLat]")
      }
    }
  }
}