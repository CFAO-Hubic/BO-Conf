Class CFAO.HUBIC.BofficeConf.messages.validateForexMsg Extends Ens.Response
{

Property invalid As %Library.DynamicArray;

Property duplicate As %Library.DynamicArray;

Property inTab As %Library.DynamicArray;

Property processed As %Library.DynamicArray;

Property status As %Integer;

Storage Default
{
<Data name="validateForexMsgDefaultData">
<Subscript>"validateForexMsg"</Subscript>
<Value name="1">
<Value>invalid</Value>
</Value>
<Value name="2">
<Value>duplicate</Value>
</Value>
<Value name="3">
<Value>inTab</Value>
</Value>
<Value name="4">
<Value>processed</Value>
</Value>
<Value name="5">
<Value>status</Value>
</Value>
</Data>
<DefaultData>validateForexMsgDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
