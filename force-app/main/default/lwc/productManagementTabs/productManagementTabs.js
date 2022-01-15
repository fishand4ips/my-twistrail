import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProducts from '@salesforce/apex/ProductController.getProducts';
import fetchPricebookEntries from '@salesforce/apex/ProductController.getPricebookEntries';
import fetchPricebooks from '@salesforce/apex/ProductController.getPricebooks';

const CURRENT_PAGE = 1;
const PAGE_LENGTH = 10;

export default class ProductManagementTabs extends LightningElement {
    
    @track isLoading = true;
    @track products;
    @track pricebooks;
    @track pricebookEntries;
    @track page = CURRENT_PAGE;
    @track pageLength = PAGE_LENGTH;
    @track totalProducts;
    @track sortedColumn;
    @track sortedDirection = 'asc';
    @track initialProducts;
    @track errors;
    @track message;

    get totalPage() {
        return Math.ceil(this.totalProducts / this.pageLength);
    }

    get currentPage() {
        return this.page;
    }

    get controlNext() {
        if (this.totalPage === this.currentPage) {
            return 'control-next';
        }
        return '';
    }

    get controlPrevious() {
        if (this.currentPage <= 0) {
            return 'control-previous';
        }
        return '';
    }

    connectedCallback() {
        this._fetchProducts();
        this._fetchPricebookEntries();
        this._fetchPricebooks();
    }

    _fetchProducts() {
        fetchProducts()
            .then(products => {
                if (products.length) {
                    this.products = products;
                    this.totalProducts = products.length;
                    this.initialProducts = this.products;
                    console.log('products::: ' + JSON.stringify(products));
                } else {
                    this.message = 'No Product records'
                }
            })
            .catch(errorProducts => {
                console.error('error::: ' + errorProducts);
                this.displayMessage('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    _fetchPricebookEntries() {
        fetchPricebookEntries()
            .then(pricebookEntries => {
                console.log('entries::: ' + JSON.stringify(pricebookEntries));
                this.pricebookEntries = pricebookEntries;
            })
            .catch(errorPricebookEntries => {
                console.error('error::: ' + errorPricebookEntries);
            })
    }

    _fetchPricebooks() {
        fetchPricebooks()
            .then(pricebooks => {
                this.pricebooks = pricebooks;
                console.log('pricebooks::: ' + JSON.stringify(pricebooks));
            })
            .catch(errorPricebooks => {
                console.error('error::: ' + errorPricebooks);
            })
    }

    sortRecs(event) {
        let colName = event.target.name;
        if (this.sortedColumn === colName) {
            this.sortedDirection = (this.sortedDirection === 'asc' ? 'desc' : 'asc');
        }
        else {
            this.sortedDirection = 'asc';
        }
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        this.sortedColumn = colName;
        this.products = JSON.parse(JSON.stringify(this.products)).sort((a, b) => {
            a = a[colName] ? a[colName].toLowerCase() : '';
            b = b[colName] ? b[colName].toLowerCase() : '';
            return a > b ? 1 * isReverse : -1 * isReverse;
        });
    }

    handleKeyChange(event) {  
        const searchKey = event.target.value.toLowerCase();  
        if (searchKey) {  
            this.products = this.initialProducts;
             if (this.products) {
                let recs = [];
                for (let rec of this.products) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.products = recs;
            }
        } else {
            this.products = this.initialProducts;
        }
    }  

    nextPage() {
        let results = [];
        if (this.page <= (Math.floor(this.totalProducts / this.pageLength))) {
            this.page = this.page + 1;
            for(let i = 0; i < this.pageLength; i++){
                if ((i + (this.page * this.pageLength)) < this.totalProducts){
                    results.push(this.products[i + (this.page * this.pageLength)]);
                }
            }
            this.products = results;
        }
    }   

    previousPage() {
        let results = [];
        if (this.page >= 1) {
            this.page = this.page - 1;
            for (let i = 0; i < this.pageLength; i++) {
                if ((i + (this.page * this.pageLength)) < this.totalProducts) {
                    results.push(this.products[i + (this.page * this.pageLength)]);
                }            
            }
            this.products = results;
        }
    }

    displayMessage(eventTitle, eventMessage, eventVariant) {
        const evt = new ShowToastEvent({
            title: eventTitle,
            message: eventMessage,
            variant: eventVariant,
        });
        this.dispatchEvent(evt);
    }
}