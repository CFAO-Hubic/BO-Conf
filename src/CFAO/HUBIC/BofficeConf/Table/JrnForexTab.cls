Class CFAO.HUBIC.BofficeConf.Table.JrnForexTab Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property JrnForexRcds As array Of CFAO.HUBIC.BofficeConf.Table.JrnForexRecords;

Storage Default
{
<Data name="JrnForexRcds">
<Attribute>JrnForexRcds</Attribute>
<Structure>subnode</Structure>
<Subscript>"JrnForexRcds"</Subscript>
</Data>
<Data name="JrnForexTabDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofF369.JrnForexTabD</DataLocation>
<DefaultData>JrnForexTabDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofF369.JrnForexTabD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofF369.JrnForexTabI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofF369.JrnForexTabS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
