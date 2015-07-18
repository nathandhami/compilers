package com.cmpt470g8.boardio;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.support.v4.widget.DrawerLayout;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import java.util.ArrayList;


public class LandingPage extends ActionBarActivity
        implements NavigationDrawerFragment.NavigationDrawerCallbacks {

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment;
    private ListView mDrawerList;
    private ArrayAdapter<String> mAdapter;
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public int loggedIn = 0;
    ListView list;
    ArrayList<String> listItems;
    ArrayAdapter<String> adapter;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_landing_page);

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);
        mTitle = getTitle();

        // Set up the drawer.
        mNavigationDrawerFragment.setUp(R.id.navigation_drawer,(DrawerLayout) findViewById(R.id.drawer_layout));
        mDrawerList = (ListView) findViewById(R.id.navList);
        list = (ListView)findViewById(R.id.activityList);
        listItems = new ArrayList<>();
        Intent intent = getIntent();
        loggedIn = intent.getIntExtra(EXTRA_MESSAGE, 0);
        adapter = new ArrayAdapter<>(getApplicationContext(), android.R.layout.simple_list_item_1, listItems);
        list.setAdapter(adapter);
        loadActivities(loggedIn);

        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(LandingPage.this, Details.class);
                intent.putExtra(EXTRA_MESSAGE, position);
                startActivity(intent);
            }
        });
    }

    @Override
    public void onNavigationDrawerItemSelected(int position) {
        // update the main content by replacing fragments
        FragmentManager fragmentManager = getSupportFragmentManager();
        fragmentManager.beginTransaction()
                .replace(R.id.container, PlaceholderFragment.newInstance(position + 1))
                .commit();
    }

    public void onSectionAttached(int number) {
        Intent intent;
        int message;
        switch (number) {
            case 1:
                intent = new Intent(this, MapsActivity.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 2:
                intent = new Intent(this, CreateEvent.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 3:
                intent = new Intent(this, Profile.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 4:
                intent = new Intent(this, Buddies.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 5:
                intent = new Intent(this, SettingsActivity.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
        }
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setTitle(mTitle);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!mNavigationDrawerFragment.isDrawerOpen()) {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.landing_page, menu);
            restoreActionBar();
            return true;
        }
        super.onCreateOptionsMenu(menu);
        if (loggedIn == 1)
            menu.add(0,0, 0, "Log Out");
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {
        /**
         * The fragment argument representing the section number for this
         * fragment.
         */
        private static final String ARG_SECTION_NUMBER = "section_number";

        /**
         * Returns a new instance of this fragment for the given section
         * number.
         */
        public static PlaceholderFragment newInstance(int sectionNumber) {
            PlaceholderFragment fragment = new PlaceholderFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        public PlaceholderFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_landing_page, container, false);
            return rootView;
        }

        @Override
        public void onAttach(Activity activity) {
            super.onAttach(activity);
            ((LandingPage) activity).onSectionAttached(
                    getArguments().getInt(ARG_SECTION_NUMBER));
        }
    }

    public void loadActivities(int loggedIn){
        for (int i=1; i<=30; ++i){
            listItems.add("Test Activity " + i);
        }
        adapter.notifyDataSetChanged();
    }

    public void create(View view){
        Intent intent = new Intent(this, CreateEvent.class);
        int message = 0;
        intent.putExtra(EXTRA_MESSAGE, message);
        startActivity(intent);
    }
}
