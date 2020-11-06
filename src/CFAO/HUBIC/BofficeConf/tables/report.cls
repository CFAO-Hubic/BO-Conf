Class CFAO.HUBIC.BofficeConf.tables.report Extends (CFAO.HUBIC.Report.AbstractRecord, %XML.Adaptor) [ Inheritance = right ]
{

Property TypeFichier As %String(MAXLEN = 20);

ClassMethod insert(fluxName, fileName, fileType, status = 0) As %Status
{
    set newLine = ..%New()
    set newLine.FileInTime = $zdt($h, 3)
    set newLine.FileOutTime = $zdt($h, 3)
    set newLine.SourceFileName = fileName
    set newLine.Emetteur = "EAI"
    set newLine.Recepteur = "Back Office"
    set newLine.NomFlux = fluxName
    set newLine.TypeFichier = fileType
    set newLine.Status = status

    return newLine.%Save()
}

Storage Default
{
<Data name="reportDefaultData">
<Subscript>"report"</Subscript>
<Value name="1">
<Value>TypeFichier</Value>
</Value>
</Data>
<DefaultData>reportDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
