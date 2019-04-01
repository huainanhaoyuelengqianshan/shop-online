<template>
  <div>
    <a-layout>
      <Header></Header>
      <a-layout-content>
        <router-view></router-view>
      </a-layout-content>
    </a-layout>
  </div>
</template>
<script>
    import Header from './components/Header'
    export default {
        name: 'App',
        components: {
          Header
        }
    }
</script>
<style>
  #components-layout-demo-fixed .logo {
    width: 120px;
    height: 31px;
    background: rgba(255,255,255,.2);
    margin: 16px 24px 16px 0;
    float: left;
  }
</style>
