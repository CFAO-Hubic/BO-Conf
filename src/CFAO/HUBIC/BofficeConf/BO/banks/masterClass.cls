Class CFAO.HUBIC.BofficeConf.BO.banks.masterClass Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Method save(data As %Library.DynamicObject, match As %Integer) As %Status
{
	set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.bank).save(data, match)

	set response = {}

	If 'tSC {
		set response.status = 0
    	set response.message = "Erreur lors de l'enregistrement de la confirmation : "_data.bankFileName
		return response
	}

	set idEaiBank = tSC

	if match {
		set tSC = ##class(CFAO.HUBIC.BofficeConf.tables.forex).match(data, match)

		if 'tSC {
			set response.status = 0
			set response.message = "Erreur lors de la mise à jour de la ligne forex : "_data.idEaiForex
			return response
		}

		set tSC = ##class(CFAO.HUBIC.BofficeConf.functions.commons).sendConfEmail(data.idEaiBank)

		if 'tSC {
			set response.status = 0
			set response.message = tSC
			return response
		}
	}

	set response.status = 1

	return response
}

Method match(data As %Library.DynamicObject) As %Library.DynamicObject
{
	if data.tradeDate 	= "" {set tradeDate = ""}		else {set tradeDate		= " AND tradeDate = " _ data.tradeDate}
	if data.valueDate 	= "" {set valueDate = ""}		else {set valueDate 	= " AND valueDate = " _ data.valueDate}
	if data.maturityDate= "" {set maturityDate = ""}	else {set maturityDate	= " AND maturityDate = " _ data.maturityDate}
	if data.bank		= "" {set bank = ""} 			else {set bank			= " AND bank = " _ data.bank}
	if data.deviseBuy 	= "" {set deviseBuy = ""}		else {set deviseBuy 	= " AND deviseBuy = " _ data.deviseBuy}
	if data.deviseSell 	= "" {set deviseSell = ""}		else {set deviseSell 	= " AND deviseSell = " _ data.deviseSell}
	if data.amountBuy 	= "" {set amountBuy = ""}		else {set amountBuy 	= " AND amountBuy = " _ data.amountBuy}
	if data.amountSell 	= "" {set amountSell = ""}		else {set amountSell 	= " AND amountSell = " _ data.amountSell}
	if data.term 		= "" {set term = ""}			else {set term			= " AND term = " _ data.term}
	if data.spot 		= "" {set spot = ""}			else {set spot			= " AND spot = " _ data.spot}
	if data.sens 		= "" {set sens = ""}			else {set sens			= " AND sens = " _ data.sens}
	if data.confType	= "" {set confType = ""}		else {set confType		= " AND confType LIKE '%" _ data.confType_"%'"}

	set request =
		"SELECT "
			_"COUNT(*) AS ""match"","
			_"idForex,"
			_"ID AS ""idEaiForex"","
			_"confType "
		_"FROM CFAO_HUBIC_BofficeConf_tables.forex "
		_"WHERE "
			_"matchStatus = 0"
			_tradeDate
			_valueDate
			_maturityDate
			_bank
			_deviseBuy
			_amountBuy
			_term
			_spot
			_sens
			_confType
	
	return ##class(CFAO.PARAM.PORTAL.utils).query(request).%Get(0)
}

}
