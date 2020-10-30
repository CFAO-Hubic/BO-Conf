Class CFAO.HUBIC.BofficeConf.messages.validateForexMsg Extends Ens.Response
{

Property invalid As %String(MAXLEN = 99999);

Property duplicate As %String(MAXLEN = 99999);

Property inTab As %String(MAXLEN = 99999);

Property processed As %String(MAXLEN = 99999);

Property fileName As %String(MAXLEN = 999);

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
<Value name="6">
<Value>fileName</Value>
</Value>
</Data>
<DefaultData>validateForexMsgDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
