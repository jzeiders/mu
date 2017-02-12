import React from 'react';
import {render} from 'react-dom';
import {AppContainer} from 'react-hot-loader';
import App from './app.jsx';
import styles from './index.scss';
import {createStore} from 'redux'
import {Provider} from 'react-redux';
import reducer from './reducers'

const store = createStore(reducer, window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__());
if (module && module.hot) {
  module
    .hot
    .accept('./reducers', () => {
      const nextRootReducer = require('./reducers/index');
      store.replaceReducer(nextRootReducer);
    });
}

render(
  <Provider store={store} ><App /></Provider>, document.querySelector("#app"));

if (module && module.hot) {
  module
    .hot
    .accept('./app.jsx', () => {
      const App = require('./app.jsx').default;
      render(
        <Provider store={store}>
        <App />
      </Provider>, document.querySelector("#app"));
    });
}
