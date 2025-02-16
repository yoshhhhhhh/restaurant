import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import HomePage from './pages/HomePage';
import RestaurantList from './pages/RestaurantList';
import RestaurantProfile from './pages/RestaurantProfile';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import UserProfile from './pages/UserProfile';
import ReviewForm from './components/ReviewForm';
import SearchBar from './components/SearchBar';
import Navigation from './components/Navigation';
import './App.css';

function App() {
  return (
    <Router>
      <Navigation />
      <div className="container">
        <Switch>
          <Route path="/" exact component={HomePage} />
          <Route path="/restaurants" exact component={RestaurantList} />
          <Route path="/restaurants/:id" component={RestaurantProfile} />
          <Route path="/login" component={LoginPage} />
          <Route path="/signup" component={SignupPage} />
          <Route path="/profile" component={UserProfile} />
          <Route path="/review/:restaurantId" component={ReviewForm} />
          <Route path="/search" component={SearchBar} />
        </Switch>
      </div>
    </Router>
  );
}

export default App;
