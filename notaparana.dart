
import 'package:notapr2json/util.dart';
import "dart:html" as html;

import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

void fill_company_data(Map<String, dynamic> json, String html) {
  Document document = parse(html);
  Element? divConteudo = document.getElementById('conteudo');
  List<Element> divs = divConteudo!.querySelectorAll('div');
  List<Element> place = divs[1].querySelectorAll('div');

  json['local']['name'] = clearText(place[0].text);
  String cnpj = clearText(place[1].text);
  if (cnpj.contains('CNPJ:')) {
    cnpj = cnpj.replaceAll('CNPJ:', '').trim();
  }
  json['local']['cnpj'] = cnpj;
  json['local']['address'] = clearText(place[2].text);
}

void fillItems(Map<String, dynamic> json, String html) {
  Document document = parse(html);
  List<Element> tableResult = document.getElementById('tabResult')!.querySelectorAll('tr');
  for (Element row in tableResult) {
    List<Element> tds = row.querySelectorAll('td');
    FillItensItem(json, tds);
  }
}

void FillItensItem(Map<String, dynamic> json, List<Element> tds) {
  Map<String, dynamic> json_item = {};
  for (Element column in tds) {
    List<Element> spans = column.querySelectorAll('span');
    for (Element span in spans) {
      String value = clearText(span.text);
      String clazz = span.classes.first;
      if (clazz == 'txtTit2') {
        json_item['name'] = value;
      }
      if (clazz == 'Rqtd') {
        json_item['quantity'] = value.replaceAll("Qtde.:", '').trim();
      }
      if (clazz == 'RUN') {
        json_item['unit'] = value.replaceAll("UN: ", '').trim();
      }
      if (clazz == 'RvlUnit') {
        json_item['unitaryValue'] = value.replaceAll("Vl. Unit.:", '').trim();
      }
      if (clazz == 'valor') {
        json_item['totalValue'] = value.trim();
      }
      if (clazz == 'RCod') {
        json_item['code'] = RegExp(r'\d+').firstMatch(value)![0];
      }
    }
  }
  json['itens'].add(json_item);
}

void FillNfceTotals(Map<String, dynamic> json, Document soup) {
  Element? totals = soup.querySelector("#totalNota");
  List<Element> divs = totals!.querySelectorAll('div');
  for (Element div in divs) {
    String label = clearText(div.querySelector('label')!.text);
    String value = clearText(div.querySelector('span')!.text);
    if (label == 'Qtd. total de itens:') {
      json['totals']['quantityItens'] = value;
    }
    if (label == 'Valor total R\$:') {
      json['totals']['total'] = value;
    }
    if (label == 'Descontos R\$:') {
      json['totals']['discounts'] = value;
    }
    if (label.contains('Informação dos Tributos Totais Incidentes')) {
      json['totals']['taxes'] = value;
    }
    if (label == 'Valor a pagar R\$:') {
      json['totals']['valueToPay'] = value;
    }
  }
}

void fillNfceInfos(Map<String, dynamic> json, String html) {
  var soup = parse(html);
  var divInfo = soup.getElementById('infos');
  var divs = divInfo!.getElementsByTagName('div');
  for (var div in divs) {
    var h4Tag = div.getElementsByTagName('h4');
    if (h4Tag.isEmpty) {
      continue;
    }
    if (h4Tag[0].text == 'Informações gerais da Nota') {
      fillNfceInfoGeneral(json, div);
    }
    if (h4Tag.isNotEmpty && h4Tag[0].text == 'Chave de acesso') {
      var key = div.getElementsByTagName('span')[0];
      json['nfce']['chave'] = normalizeKey(key.text);
    }
  }
}

void fillNfceInfoGeneral(Map<String, dynamic> json, Element div) {
  var lis = div.getElementsByTagName('li');
  for (var li in lis) {
    if (li == null || li.text == '\n') {
      continue;
    }
    if (li is Element) {
      var value = li.text.trim();
      if (value == 'Número:') {
        json['nfce']['numero'] = li.nextElementSibling!.text.trim();
      }
      if (value == 'Série:') {
        json['nfce']['serie'] = li.nextElementSibling!.text.trim();
      }
      if (value == 'Emissão:') {
        var dateList = li.nextElementSibling!.text.trim().split(' ');
        json['nfce']['date'] = dateList[0] + ' ' + dateList[1];
      }
      if (value == 'Protocolo de Autorização:') {
        json['nfce']['protocolo'] =
            li.nextElementSibling!.text.trim().split(' ')[0];
      }
      if (li.text.contains('Ambiente de Produção')) {
        value = li.text.split('-')[1];
        json['nfce']['version'] = clearText(value)
            .replaceFirst('Versão XML: ', '')
            .trim();
      }
    }
  }
}
