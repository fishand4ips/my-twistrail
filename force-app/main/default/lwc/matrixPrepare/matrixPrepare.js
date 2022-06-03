import { LightningElement } from "lwc";

export default class MatrixPrepare extends LightningElement {
  method1() {
    let ss = new WeakMap();
    ss.set("1", 2);
    console.log(ss);
  }
}
