import {LightningElement, wire, track} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getCarModelsInfo from '@salesforce/apex/CarModelsPriceInfoController.getCarModelsInfo';
import fetchCarPrice from '@salesforce/apex/CarModelsPriceInfoController.fetchCarPrice';

import MODEL_UNIQUE_CODE from "@salesforce/schema/Car_Model__c.Model_Unique_Code__c";
import MODEL_NAME from "@salesforce/schema/Car_Model__c.Name";
import MODEL_BRAND from "@salesforce/schema/Car_Model__c.Brand__c";

import brandLbl from '@salesforce/label/c.CM_Brand';
import carModelsTtl from '@salesforce/label/c.CM_CarModels';
import selectCarModelLbl from '@salesforce/label/c.CM_SelectCarModel';
import chooseCarModelLbl from '@salesforce/label/c.CM_ChooseCarModel';
import loadingCarModelsLbl from '@salesforce/label/c.CM_LoadingCarModels';
import loadingCarPriceLbl from '@salesforce/label/c.CM_LoadingCarPrice';
import marketPriceLbl from '@salesforce/label/c.CM_MarketPrice';
import modelNameLbl from '@salesforce/label/c.CM_ModelName';
import pleaseSelectCarLbl from '@salesforce/label/c.CM_PleaseSelectCar';
import infoRetrievalErrorLbl from '@salesforce/label/c.CM_InfoRetrievalError';
import priceRetrievalErrorLbl from '@salesforce/label/c.CM_PriceRetrievalError';

export default class CarModelsPriceInfo extends LightningElement {
    @track carModels = [];
    @track carOptions = [];
    @track selectedCar;
    @track carPrice;
    @track isPriceLoading;

    labels = {
        brandLbl,
        carModelsTtl,
        selectCarModelLbl,
        chooseCarModelLbl,
        loadingCarModelsLbl,
        loadingCarPriceLbl,
        marketPriceLbl,
        modelNameLbl,
        pleaseSelectCarLbl,
        infoRetrievalErrorLbl,
        priceRetrievalErrorLbl
    }

    @wire(getCarModelsInfo, {fields: [MODEL_NAME.fieldApiName, MODEL_BRAND.fieldApiName, MODEL_UNIQUE_CODE.fieldApiName]})
    wiredCarModelsWithFields({error, data}) {
        if (data) {
            this.carModels = data;
            this.carOptions = data.map(car => ({
                label: `${car[MODEL_NAME.fieldApiName]} ${car[MODEL_BRAND.fieldApiName]}`,
                value: car.Id
            }));
        } else if (error) {
            this.showErrorNotification(this.labels.infoRetrievalErrorLbl, error);
        }
    }

    handleCarSelection(event) {
        const selectedModelId = event.target.value;
        this.selectedCar = this.carModels.find(car => car.Id === selectedModelId);
        if (this.selectedCar) {
            this.fetchPrice(this.selectedCar[MODEL_UNIQUE_CODE.fieldApiName]);
        }
    }

    fetchPrice(uniqueCode) {
        this.isPriceLoading = true;
        fetchCarPrice({uniqueCode})
            .then(price => {
                this.carPrice = price;
            })
            .catch(error => {
                this.carPrice = null;
                this.showErrorNotification(this.labels.priceRetrievalErrorLbl, error);
            }).finally(_ => {
            this.isPriceLoading = false;
        });
    }

    get hasSelectedCar() {
        return !!this.selectedCar;
    }

    get selectedCarId() {
        return this.selectedCar?.id
    }

    showErrorNotification(titleError, error) {
        const evt = new ShowToastEvent({
            title: titleError,
            message: error.body?.message,
            variant: "error",
        });
        this.dispatchEvent(evt);
    }
}