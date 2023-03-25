
import { useState } from 'react';


const algosdk = require('algosdk');

// create client object to connect to sandbox's algod client
const algodToken = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const algodServer = 'http://localhost';
const algodPort = 4001;
const apiKey= 'Sq7UC7frimaLx8xBrIydj82PitGi3IJv7dqTlRi';

const algodClient = new algosdk.Algodv2(algodToken, algodServer, algodPort,apiKey);

const App = () => {
  const [organizationName, setOrganizationName] = useState('');
  const [location, setLocation] = useState('');
  const [productQuantity, setProductQuantity] = useState(0);
  const [productImage, setProductImage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Convert image to base64 string
    const reader = new FileReader();
    reader.readAsDataURL(productImage);
    reader.onloadend = async () => {
      const base64data = reader.result;
      const account1_mnemonic = "suspect lecture drama desk lemon embody coin chase include best track wisdom inspire burst they void final build true this museum note above absorb confirm";

      // Create the asset on the Algorand blockchain
      const params = await algodClient.getTransactionParams().do();
      const txn = algosdk.makeAssetCreateTxnWithSuggestedParamsFromObject({
        from: algosdk.mnemonicToSecretKey(account1_mnemonic).addr,
        assetName: organizationName,
        unitName: location,
        total: productQuantity,
        decimals: 0,
        note: algosdk.encodeObj({ image: base64data }),
        suggestedParams: params,
      });

      const signedTxn = txn.sign(algosdk.mnemonicToSecretKey(account1_mnemonic).sk);

      await algodClient.sendRawTransaction(signedTxn.blob).do();
      const lastTransaction = (await algodClient.transactionByAddress('UVJPTKXAMH3CHYIM2TCBQDBXYF7RIVRFHBUM5O77VKJHMA7VMJRJPMH6SI', 'max')).transactions[0];
      console.log(lastTransaction.tx);

      
    };
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label>
          Organization Name:
          <input type="text" value={organizationName} onChange={(e) => setOrganizationName(e.target.value)} />
        </label>
        <br />
        <label>
          Location:
          <input type="text" value={location} onChange={(e) => setLocation(e.target.value)} />
        </label>
        <br />
        <label>
          Product Quantity:
          <input type="number" value={productQuantity} onChange={(e) => setProductQuantity(e.target.value)} />
        </label>
        <br />
        <label>
          Product Image:
          <input type="file" accept="image/*" onChange={(e) => setProductImage(e.target.files[0])} />
        </label>
        <br />
        <button type="submit">Create Asset</button>
      </form> 
    </div>
  );
}
export default App;