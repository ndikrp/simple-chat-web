import '../style.css';
import { createApp } from 'vue';
import PrimeVue from 'primevue/config';
import Lara from '@primevue/themes/lara';
import App from '../App.vue';

// Import PrimeIcons
import 'primeicons/primeicons.css';

const app = createApp(App);
app.use(PrimeVue, {
    theme: {
        preset: Lara
    }
});
app.mount('#app');
