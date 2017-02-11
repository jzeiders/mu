import React from 'react';
import { render } from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import App from './app.jsx';
import styles from './index.scss'

render( <AppContainer  className={styles.maxHeight}><App className={styles.maxHeight}/></AppContainer>, document.querySelector("#app"));

if (module && module.hot) {
  module.hot.accept('./app.jsx', () => {
    const App = require('./app.jsx').default;
    render(
      <AppContainer className={styles.maxHeight}>
        <App className={styles.maxHeight}/>
      </AppContainer>,
      document.querySelector("#app")
    );
  });
}
