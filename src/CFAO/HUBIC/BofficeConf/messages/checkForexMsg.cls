Class CFAO.HUBIC.BofficeConf.messages.checkForexMsg Extends Ens.Response
{

Property forex As %String(MAXLEN = 99999);

Property bank As %String(MAXLEN = 99999);

Property status As %Integer;

Storage Default
{
<Data name="checkForexMsgDefaultData">
<Subscript>"checkForexMsg"</Subscript>
<Value name="1">
<Value>forex</Value>
</Value>
<Value name="2">
<Value>bank</Value>
</Value>
<Value name="3">
<Value>status</Value>
</Value>
</Data>
<DefaultData>checkForexMsgDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
