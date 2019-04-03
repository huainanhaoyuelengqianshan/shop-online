<template>
    <div>
        <!--<div className="logo">-->
          <!--<img src="/logo.png" alt=""/>-->
        <!--</div>-->
        <a-menu class="menu"
                theme='dark'
                mode='horizontal'
                :defaultSelectedKeys="['1']"
        >
          <a-menu-item key="/">
            <router-link to='/'>商品列表</router-link>
          </a-menu-item>
          <a-menu-item key="/add">
            <router-link to='/add'>添加商品</router-link>
          </a-menu-item>
            <a-menu-item key="/host">
                <router-link to='/host'>个人主页</router-link>
            </a-menu-item>
        </a-menu>
    </div>
</template>

<script>
export default {
  name: 'Header',
  // props:{
  //     SelectedKeys:
  // }
  data () {
    return {
        // defaultSelectedKeys: this.props.location.pathname
    }
  },
    watch: {
        $route(to, from) {
            console.log(this.$route.path);
        }
    },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .menu{
      line-height:64px
  }

</style>
