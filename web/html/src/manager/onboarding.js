'use strict';

const React = require("react");
const ReactDOM = require("react-dom");
const Buttons = require("../components/buttons");
const AsyncButton = Buttons.AsyncButton;
const Panel = require("../components/panel").Panel;
const Table = require("../components/table2").Table;
const Network = require("../utils/network");
const Functions = require("../utils/functions");
const Comparators = Functions.Comparators;
const Filters = Functions.Filters;
const Renderer = Functions.Renderer;
const STables = require("../components/tableng.js");
const STable = STables.STable;
const SColumn = STables.SColumn;
const SHeader = STables.SHeader;
const SCell = STables.SCell;

function listKeys() {
    return Network.get("/rhn/manager/api/minions/keys").promise;
}

function minionToList(idFingerprintMap, state) {
   return Object.keys(idFingerprintMap).map(key => {
       return {
           "id": key,
           "fingerprint": idFingerprintMap[key],
           "state": state
       };
   });
}

function processData(keys) {
   return ["minions", "minions_rejected", "minions_pre", "minions_denied"].reduce((acc, key) => {
       return acc.concat(minionToList(keys[key], key));
   }, []);
}

function acceptKey(key) {
    return Network.post("/rhn/manager/api/minions/keys/" + key + "/accept").promise;
}

function deleteKey(key) {
    return Network.post("/rhn/manager/api/minions/keys/" + key + "/delete").promise;
}

function rejectKey(key) {
    return Network.post("/rhn/manager/api/minions/keys/" + key + "/reject").promise;
}

function actionsFor(id, state, update, enabled) {
    const acc = () => <AsyncButton disabled={enabled?"":"disabled"} key="accept" title="accept" icon="check" action={() => acceptKey(id).then(update)} />;
    const rej = () => <AsyncButton disabled={enabled?"":"disabled"} key="reject" title="reject" icon="times" action={() => rejectKey(id).then(update)} />;
    const del = () => <AsyncButton disabled={enabled?"":"disabled"} key="delete" title="delete" icon="trash" action={() => deleteKey(id).then(update)} />;
    const mapping = {
        "minions": [del],
        "minions_pre": [acc, rej],
        "minions_rejected": [del],
        "minions_denied": [del]
    };
    return (
      <div className="pull-right btn-group">
         { mapping[state].map(fn => fn()) }
      </div>
    );
}

const stateMapping = {
    "minions": {
        uiName: t("accepted"),
        label: "success"
    },
    "minions_pre": {
        uiName: t("pending"),
        label: "info"
    },
    "minions_rejected": {
        uiName: t("rejected"),
        label: "warning"
    },
    "minions_denied": {
        uiName: t("denied"),
        label: "danger"
    }
}

const stateUiName = (state) => stateMapping[state].uiName;

function labelFor(state) {
    const mapping = stateMapping[state];
    return <span className={"label label-" + mapping.label}>{ mapping.uiName }</span>
}

function Highlight(props) {
  var text = props.text;
  var high = props.highlight;

  if (!props.enabled) {
    return <span>{text}</span>
  }

  var chunks = text.split(new RegExp("^" + high));

  return <span>{chunks
    .map((e, i) => e == "" ? <span key="highlight" style={{backgroundColor: "#f0ad4e", borderRadius: "2px"}}>{high}</span> : <span key={i}>{e}</span>)}</span>;
}

class Onboarding extends React.Component {

  constructor(props) {
    super();
    ["sortByName", "searchData", "sortByFingerprint", "sortByState", "rowKey", "reloadKeys"].forEach(method => this[method] = this[method].bind(this));
    this.state = {
        keys: [],
        isOrgAdmin: false
    };
    this.reloadKeys();
  }

  reloadKeys() {
    return listKeys().then(data => {
        this.setState({
            keys: processData(data["fingerprints"]),
            isOrgAdmin: data["isOrgAdmin"]
        });
    });
  }

  rowKey(rowData) {
    return rowData.id;
  }

  sortByName(data, direction) {
    return data.sort((a, b) => direction * a.id.toLowerCase().localeCompare(b.id.toLowerCase()));
  }

  sortByFingerprint(data, direction) {
     return data.sort((a, b) => {
         if (a.fingerprint > b.fingerprint) {
           return direction * 1;
         }
         if (a.fingerprint < b.fingerprint) {
           return direction * -1;
         }
         return 0
     });
  }

  sortByState(data, direction) {
     return data.sort((a, b) => {
         if (a.state > b.state) {
           return direction * 1;
         }
         if (a.state < b.state) {
           return direction * -1;
         }
         return 0
     });
  }

  searchData(data, criteria) {
      if (!criteria || criteria == "") {
        return data;
      }
      return data.filter((e) => e.id.startsWith(criteria) || e.fingerprint.startsWith(criteria));
  }

  render() {
    const panelButtons = <div className="pull-right btn-group">
      <AsyncButton id="reload" icon="refresh" name="Refresh" text action={this.reloadKeys} />
    </div>;
    return (
    <span>
        <h4>{this.state.selectedProductId}</h4>
        <Panel title="Onboarding" icon="fa-desktop" button={ panelButtons }>
            <STable data={this.state.keys} searchFn={this.searchData} rowKeyFn={this.rowKey} pageSize={15}>
              <SColumn columnKey="id" width="30%">
                <SHeader sortFn={this.sortByName}>{t('Name')}</SHeader>
                <SCell value={ (row, table) => {
                     if(row.state == "minions") {
                        return <a href={ "/rhn/manager/minions/" + row.id }>
                            <Highlight enabled={table.state.dataModel.filtered}
                              text={row.id}
                              highlight={table.state.dataModel.filteredText}/>
                            </a>;
                     } else {
                        return <Highlight enabled={table.state.dataModel.filtered}
                            text={row.id}
                            highlight={table.state.dataModel.filteredText}/>;
                     }
                    }}/>
              </SColumn>
              <SColumn columnKey="fingerprint" width="50%">
                <SHeader sortFn={this.sortByFingerprint}>{t('Fingerprint')}</SHeader>
                <SCell value={ (row, table) => <Highlight enabled={table.state.dataModel.filtered}
                            text={row.fingerprint}
                            highlight={table.state.dataModel.filteredText}/> } />
              </SColumn>
              <SColumn columnKey="state" width="10%">
                <SHeader sortFn={this.sortByState}>{t('State')}</SHeader>
                <SCell value={ (row) => labelFor(row.state) } />
              </SColumn>
              <SColumn width="10%">
                <SHeader>{t('Actions')}</SHeader>
                <SCell value={ (row) => actionsFor(row.id, row.state, this.reloadKeys, this.state.isOrgAdmin)} />
              </SColumn>
            </STable>
        </Panel>
    </span>
    );
  }

}

ReactDOM.render(
  <Onboarding />,
  document.getElementById('onboarding')
);
